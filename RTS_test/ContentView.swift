//
//  ContentView.swift
//  RTS_test
//
//  Created by 斎藤剛 on 2026/05/23.
//

import SwiftUI

struct ContentView: View {
    @State private var minerals = 40
    @State private var baseHealth = 100
    @State private var enemyBaseHealth = 120
    @State private var units: [RTSUnit] = [
        RTSUnit(kind: .worker, position: CGPoint(x: 96, y: 190)),
        RTSUnit(kind: .worker, position: CGPoint(x: 136, y: 220)),
        RTSUnit(kind: .soldier, position: CGPoint(x: 118, y: 280))
    ]
    @State private var enemyUnits: [RTSUnit] = [
        RTSUnit(kind: .soldier, position: CGPoint(x: 300, y: 370), target: CGPoint(x: 72, y: 72))
    ]
    @State private var selectedUnitIDs: Set<RTSUnit.ID> = []
    @State private var enemySpawnTicks = 0
    @State private var gameStatus: GameStatus = .playing

    private let playerBasePosition = CGPoint(x: 72, y: 72)
    private let mineralPosition = CGPoint(x: 278, y: 130)
    private let enemyBasePosition = CGPoint(x: 314, y: 410)
    private let soldierAttackRange: CGFloat = 42
    private let soldierAggroRange: CGFloat = 150

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                hud
                battlefield
                commandBar
            }
            .background(Color(red: 0.08, green: 0.11, blue: 0.09))

            if gameStatus != .playing {
                resultOverlay
            }
        }
        .task {
            await runGameLoop()
        }
    }

    private var hud: some View {
        HStack(spacing: 12) {
            Label("Minerals: \(minerals)", systemImage: "diamond.fill")
            Label("Base: \(baseHealth)", systemImage: "shield.fill")
            Label("Enemy: \(max(enemyBaseHealth, 0))", systemImage: "flame.fill")
            Label("Raiders: \(enemyUnits.count)", systemImage: "person.2.fill")
        }
        .font(.system(size: 13, weight: .semibold, design: .rounded))
        .foregroundStyle(.white)
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(red: 0.12, green: 0.16, blue: 0.13))
    }

    private var battlefield: some View {
        GeometryReader { proxy in
            let scale = min(proxy.size.width / 390, proxy.size.height / 520)
            let xOffset = (proxy.size.width - 390 * scale) / 2
            let yOffset = (proxy.size.height - 520 * scale) / 2

            ZStack {
                terrain
                    .frame(width: 390, height: 520)
                    .scaleEffect(scale)
                    .position(x: proxy.size.width / 2, y: proxy.size.height / 2)

                gameObjects(scale: scale, xOffset: xOffset, yOffset: yOffset)
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onEnded { value in
                        let boardPoint = CGPoint(
                            x: (value.location.x - xOffset) / scale,
                            y: (value.location.y - yOffset) / scale
                        )
                        handleTap(at: boardPoint)
                    }
            )
        }
    }

    private var terrain: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.15, green: 0.26, blue: 0.16),
                    Color(red: 0.11, green: 0.20, blue: 0.17)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Path { path in
                path.move(to: CGPoint(x: 0, y: 340))
                path.addCurve(
                    to: CGPoint(x: 390, y: 286),
                    control1: CGPoint(x: 110, y: 300),
                    control2: CGPoint(x: 230, y: 390)
                )
                path.addLine(to: CGPoint(x: 390, y: 520))
                path.addLine(to: CGPoint(x: 0, y: 520))
                path.closeSubpath()
            }
            .fill(Color(red: 0.19, green: 0.24, blue: 0.15).opacity(0.9))

            gridLines
        }
    }

    private var gridLines: some View {
        Path { path in
            stride(from: 0, through: 390, by: 39).forEach { x in
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x, y: 520))
            }
            stride(from: 0, through: 520, by: 40).forEach { y in
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: 390, y: y))
            }
        }
        .stroke(Color.white.opacity(0.06), lineWidth: 1)
    }

    private func gameObjects(scale: CGFloat, xOffset: CGFloat, yOffset: CGFloat) -> some View {
        ZStack {
            structure(
                title: "HQ",
                systemImage: "house.fill",
                color: .cyan,
                health: baseHealth,
                maxHealth: 100
            )
            .position(screenPoint(playerBasePosition, scale: scale, xOffset: xOffset, yOffset: yOffset))

            resourceNode
                .position(screenPoint(mineralPosition, scale: scale, xOffset: xOffset, yOffset: yOffset))

            structure(
                title: "Enemy",
                systemImage: "bolt.fill",
                color: .red,
                health: max(enemyBaseHealth, 0),
                maxHealth: 120
            )
            .position(screenPoint(enemyBasePosition, scale: scale, xOffset: xOffset, yOffset: yOffset))

            ForEach(enemyUnits) { enemyUnit in
                enemyUnitView(enemyUnit)
                    .position(screenPoint(enemyUnit.position, scale: scale, xOffset: xOffset, yOffset: yOffset))
            }

            ForEach(units) { unit in
                unitView(unit)
                    .position(screenPoint(unit.position, scale: scale, xOffset: xOffset, yOffset: yOffset))
                    .onTapGesture {
                        toggleSelection(for: unit.id)
                    }
            }
        }
    }

    private var resourceNode: some View {
        VStack(spacing: 4) {
            Image(systemName: "diamond.fill")
                .font(.system(size: 26))
            Text("Ore")
                .font(.system(size: 11, weight: .bold))
        }
        .foregroundStyle(.yellow)
        .frame(width: 66, height: 58)
        .background(Color.black.opacity(0.18), in: RoundedRectangle(cornerRadius: 8))
    }

    private var commandBar: some View {
        HStack(spacing: 10) {
            Button {
                selectedUnitIDs = Set(units.map(\.id))
            } label: {
                Label("Select All", systemImage: "scope")
            }
            .disabled(gameStatus != .playing)

            Button {
                trainWorker()
            } label: {
                Label("Worker 25", systemImage: "hammer.fill")
            }
            .disabled(gameStatus != .playing || minerals < 25)

            Button {
                trainSoldier()
            } label: {
                Label("Soldier 40", systemImage: "shield.lefthalf.filled")
            }
            .disabled(gameStatus != .playing || minerals < 40)
        }
        .font(.system(size: 13, weight: .semibold))
        .buttonStyle(.borderedProminent)
        .controlSize(.small)
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(Color(red: 0.12, green: 0.16, blue: 0.13))
    }

    private var resultOverlay: some View {
        VStack(spacing: 12) {
            Image(systemName: gameStatus == .clear ? "crown.fill" : "xmark.octagon.fill")
                .font(.system(size: 42, weight: .bold))
                .foregroundStyle(gameStatus == .clear ? .yellow : .red)

            Text(gameStatus == .clear ? "CLEAR" : "GAME OVER")
                .font(.system(size: 34, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)

            Text(gameStatus == .clear ? "Enemy base destroyed" : "Your base was destroyed")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white.opacity(0.78))

            Button {
                resetGame()
            } label: {
                Label("Retry", systemImage: "arrow.clockwise")
                    .font(.system(size: 16, weight: .bold))
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.top, 10)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.62))
    }

    private func unitView(_ unit: RTSUnit) -> some View {
        let isSelected = selectedUnitIDs.contains(unit.id)

        return ZStack {
            Circle()
                .stroke(isSelected ? Color.yellow : Color.clear, lineWidth: 4)
                .frame(width: 38, height: 38)

            Circle()
                .fill(unit.kind.color)
                .frame(width: 28, height: 28)
                .shadow(radius: 3, y: 2)

            Image(systemName: unit.kind.systemImage)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(.white)

            unitHealthBar(unit, tint: unit.kind.color)
                .offset(y: 24)
        }
    }

    private func enemyUnitView(_ unit: RTSUnit) -> some View {
        ZStack {
            Circle()
                .stroke(Color.red.opacity(0.45), lineWidth: 3)
                .frame(width: 36, height: 36)

            Circle()
                .fill(Color.red)
                .frame(width: 26, height: 26)
                .shadow(radius: 3, y: 2)

            Image(systemName: unit.kind.systemImage)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.white)

            unitHealthBar(unit, tint: .red)
                .offset(y: 23)
        }
    }

    private func unitHealthBar(_ unit: RTSUnit, tint: Color) -> some View {
        ProgressView(value: Double(max(unit.health, 0)), total: Double(unit.kind.maxHealth))
            .tint(tint)
            .frame(width: 32)
            .scaleEffect(x: 1, y: 0.55)
    }

    private func structure(
        title: String,
        systemImage: String,
        color: Color,
        health: Int,
        maxHealth: Int
    ) -> some View {
        VStack(spacing: 5) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(color.opacity(0.85))
                    .frame(width: 72, height: 52)
                Image(systemName: systemImage)
                    .font(.system(size: 23, weight: .bold))
                    .foregroundStyle(.white)
            }

            ProgressView(value: Double(health), total: Double(maxHealth))
                .tint(color)
                .frame(width: 70)

            Text(title)
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(.white)
        }
    }

    private func handleTap(at point: CGPoint) {
        guard gameStatus == .playing else { return }
        guard point.x >= 0, point.x <= 390, point.y >= 0, point.y <= 520 else { return }
        guard !selectedUnitIDs.isEmpty else { return }

        for index in units.indices where selectedUnitIDs.contains(units[index].id) {
            let offset = formationOffset(for: index)
            units[index].target = CGPoint(
                x: min(max(point.x + offset.width, 18), 372),
                y: min(max(point.y + offset.height, 18), 502)
            )
        }
    }

    private func toggleSelection(for id: RTSUnit.ID) {
        guard gameStatus == .playing else { return }

        if selectedUnitIDs.contains(id) {
            selectedUnitIDs.remove(id)
        } else {
            selectedUnitIDs.insert(id)
        }
    }

    private func trainWorker() {
        guard gameStatus == .playing, minerals >= 25 else { return }
        minerals -= 25
        units.append(RTSUnit(kind: .worker, position: CGPoint(x: 92, y: 112)))
    }

    private func trainSoldier() {
        guard gameStatus == .playing, minerals >= 40 else { return }
        minerals -= 40
        units.append(RTSUnit(kind: .soldier, position: CGPoint(x: 116, y: 112)))
    }

    private func resetGame() {
        minerals = 40
        baseHealth = 100
        enemyBaseHealth = 120
        units = [
            RTSUnit(kind: .worker, position: CGPoint(x: 96, y: 190)),
            RTSUnit(kind: .worker, position: CGPoint(x: 136, y: 220)),
            RTSUnit(kind: .soldier, position: CGPoint(x: 118, y: 280))
        ]
        enemyUnits = [
            RTSUnit(kind: .soldier, position: CGPoint(x: 300, y: 370), target: playerBasePosition)
        ]
        selectedUnitIDs = []
        enemySpawnTicks = 0
        gameStatus = .playing
    }

    private func runGameLoop() async {
        while !Task.isCancelled {
            try? await Task.sleep(for: .milliseconds(90))
            updateSimulation()
        }
    }

    @MainActor
    private func updateSimulation() {
        guard gameStatus == .playing else { return }

        spawnEnemySoldierIfNeeded()
        updatePlayerUnits()
        updateEnemyUnits()
        resolveCombat()
        updateGameStatus()
    }

    private func updatePlayerUnits() {
        for index in units.indices {
            move(&units[index])

            if units[index].kind == .worker, units[index].position.distance(to: mineralPosition) < 34 {
                units[index].carryTicks += 1
                if units[index].carryTicks >= 8 {
                    minerals += 1
                    units[index].carryTicks = 0
                }
            }
        }
    }

    private func updateEnemyUnits() {
        for index in enemyUnits.indices {
            if let targetIndex = nearestUnitIndex(to: enemyUnits[index].position, in: units),
               enemyUnits[index].position.distance(to: units[targetIndex].position) < soldierAggroRange {
                enemyUnits[index].target = units[targetIndex].position
            } else {
                enemyUnits[index].target = playerBasePosition
            }

            move(&enemyUnits[index])
        }
    }

    private func resolveCombat() {
        var playerDamage = Array(repeating: 0, count: units.count)
        var enemyDamage = Array(repeating: 0, count: enemyUnits.count)

        for index in units.indices where units[index].kind == .soldier {
            if let targetIndex = nearestUnitIndex(to: units[index].position, in: enemyUnits),
               units[index].position.distance(to: enemyUnits[targetIndex].position) < soldierAttackRange {
                enemyDamage[targetIndex] += units[index].kind.attackDamage
            } else if units[index].position.distance(to: enemyBasePosition) < 52, enemyBaseHealth > 0 {
                enemyBaseHealth -= units[index].kind.attackDamage
            }
        }

        for index in enemyUnits.indices where enemyUnits[index].kind == .soldier {
            if let targetIndex = nearestUnitIndex(to: enemyUnits[index].position, in: units),
               enemyUnits[index].position.distance(to: units[targetIndex].position) < soldierAttackRange {
                playerDamage[targetIndex] += enemyUnits[index].kind.attackDamage
            } else if enemyUnits[index].position.distance(to: playerBasePosition) < 52, baseHealth > 0 {
                baseHealth -= enemyUnits[index].kind.attackDamage
            }
        }

        for index in units.indices {
            units[index].health -= playerDamage[index]
        }
        for index in enemyUnits.indices {
            enemyUnits[index].health -= enemyDamage[index]
        }

        let defeatedPlayerIDs = Set(units.filter { $0.health <= 0 }.map(\.id))
        units.removeAll { $0.health <= 0 }
        enemyUnits.removeAll { $0.health <= 0 }
        selectedUnitIDs.subtract(defeatedPlayerIDs)
    }

    private func updateGameStatus() {
        if enemyBaseHealth <= 0 {
            enemyBaseHealth = 0
            gameStatus = .clear
        } else if baseHealth <= 0 {
            baseHealth = 0
            gameStatus = .gameOver
        }
    }

    private func spawnEnemySoldierIfNeeded() {
        guard enemyBaseHealth > 0 else { return }

        enemySpawnTicks += 1
        guard enemySpawnTicks >= 240 else { return }

        enemySpawnTicks = 0
        let spawnOffset = CGFloat((enemyUnits.count % 3) * 20 - 20)
        enemyUnits.append(
            RTSUnit(
                kind: .soldier,
                position: CGPoint(x: enemyBasePosition.x + spawnOffset, y: enemyBasePosition.y - 38),
                target: playerBasePosition
            )
        )
    }

    private func move(_ unit: inout RTSUnit) {
        let target = unit.target
        let position = unit.position
        let distance = position.distance(to: target)
        guard distance > 1 else { return }

        let speed = unit.kind.speed
        let step = min(speed, distance)
        let dx = (target.x - position.x) / distance * step
        let dy = (target.y - position.y) / distance * step
        unit.position.x += dx
        unit.position.y += dy
    }

    private func nearestUnitIndex(to position: CGPoint, in targetUnits: [RTSUnit]) -> Int? {
        targetUnits.indices.min { leftIndex, rightIndex in
            position.distance(to: targetUnits[leftIndex].position) < position.distance(to: targetUnits[rightIndex].position)
        }
    }

    private func formationOffset(for index: Int) -> CGSize {
        let column = index % 3 - 1
        let row = index / 3
        return CGSize(width: CGFloat(column * 22), height: CGFloat(row * 20))
    }

    private func screenPoint(
        _ boardPoint: CGPoint,
        scale: CGFloat,
        xOffset: CGFloat,
        yOffset: CGFloat
    ) -> CGPoint {
        CGPoint(x: xOffset + boardPoint.x * scale, y: yOffset + boardPoint.y * scale)
    }
}

private struct RTSUnit: Identifiable {
    let id = UUID()
    let kind: UnitKind
    var position: CGPoint
    var target: CGPoint
    var health: Int
    var carryTicks = 0

    init(kind: UnitKind, position: CGPoint, target: CGPoint? = nil) {
        self.kind = kind
        self.position = position
        self.target = target ?? position
        self.health = kind.maxHealth
    }
}

private enum UnitKind {
    case worker
    case soldier

    var color: Color {
        switch self {
        case .worker:
            return .blue
        case .soldier:
            return .green
        }
    }

    var systemImage: String {
        switch self {
        case .worker:
            return "wrench.fill"
        case .soldier:
            return "target"
        }
    }

    var speed: CGFloat {
        switch self {
        case .worker:
            return 2.1
        case .soldier:
            return 2.6
        }
    }

    var maxHealth: Int {
        switch self {
        case .worker:
            return 18
        case .soldier:
            return 28
        }
    }

    var attackDamage: Int {
        switch self {
        case .worker:
            return 0
        case .soldier:
            return 2
        }
    }
}

private enum GameStatus {
    case playing
    case clear
    case gameOver
}

private extension CGPoint {
    func distance(to other: CGPoint) -> CGFloat {
        hypot(x - other.x, y - other.y)
    }
}

#Preview {
    ContentView()
}
