//
//  ContentView.swift
//  RTS_test
//
//  Created by 斎藤剛 on 2026/05/23.
//

import SwiftUI

struct ContentView: View {
    @State private var stageIndex = 0
    @State private var minerals = 0
    @State private var baseHealth = 100
    @State private var enemyBaseHealth = 100
    @State private var units: [RTSUnit] = []
    @State private var enemyUnits: [RTSUnit] = []
    @State private var selectedUnitIDs: Set<RTSUnit.ID> = []
    @State private var selectedProductionSite: ProductionSite?
    @State private var enemySpawnTicks = 0
    @State private var gameStatus: GameStatus = .title

    private static let stages: [StageDefinition] = [
        StageDefinition(
            title: "Stage test：テスト",
            playerBasePosition: CGPoint(x: 60, y: 100),
            campPosition: CGPoint(x: 60, y: 260),
            mineralBasePosition: CGPoint(x: 195, y: 480),
            enemyBasePosition: CGPoint(x: 330, y: 400),
            oreCount: 2,
            initialMinerals: 80,
            playerBaseHealth: 120,
            enemyBaseHealth: 180,
            enemySpawnIntervalTicks: 30,
            enemySpawnPool: [.spear,],
            playerUnitPlacements: [
                UnitPlacement(kind: .worker, position: CGPoint(x: 80, y: 220)),
                UnitPlacement(kind: .shield, position: CGPoint(x: 100, y: 300)),
                UnitPlacement(kind: .sword, position: CGPoint(x: 140, y: 300)),
                UnitPlacement(kind: .spear, position: CGPoint(x: 120, y: 340)),
                UnitPlacement(kind: .bow, position: CGPoint(x: 60, y: 340)),
            ],
            enemyUnitPlacements: [
                UnitPlacement(kind: .sword, position: CGPoint(x: 300, y: 340)),
                UnitPlacement(kind: .axe, position: CGPoint(x: 340, y: 340)),
                UnitPlacement(kind: .spear, position: CGPoint(x: 280, y: 300)),
                UnitPlacement(kind: .bow, position: CGPoint(x: 360, y: 300)),
            ]
        ),
        StageDefinition(
            title: "Stage 1：勝利条件の理解",
            initialSwordCount: 1,
            enemySpawnIntervalTicks: 150
        ),
        StageDefinition(
            title: "Stage 2：戦闘の理解",
            initialSwordCount: 2,
            initialEnemyCount: 1,
            enemySpawnIntervalTicks: 100
        ),
        StageDefinition(
            title: "Stage 3：生産の理解",
            initialMinerals: 40,
            enemySpawnIntervalTicks: 100
        ),
        StageDefinition(
            title: "Stage 4：キャンプの理解",
            campPosition: CGPoint(x: 250, y: 260),
            initialMinerals: 40,
            enemySpawnIntervalTicks: 160
        ),
        StageDefinition(
            title: "Stage 5：鉱山の理解",
            oreCount: 1,
            initialWorkerCount: 1,
            initialSwordCount: 1,
            enemySpawnIntervalTicks: 200
        ),
        StageDefinition(
            title: "Stage 6：弓兵の理解",
            initialBowCount: 1,
            initialEnemyCount: 3,
            enemySpawnIntervalTicks: 40
        ),
        StageDefinition(
            title: "Stage 7：盾兵の理解",
            initialBowCount: 1,
            initialShieldCount: 1,
            initialEnemyCount: 5,
            enemySpawnIntervalTicks: 40
        ),
        StageDefinition(
            title: "Stage 8：三すくみの理解",
            enemySpawnIntervalTicks: 240,
            playerUnitPlacements: [
                UnitPlacement(kind: .sword, position: CGPoint(x: 140, y: 300)),
                UnitPlacement(kind: .spear, position: CGPoint(x: 120, y: 340)),
                UnitPlacement(kind: .axe, position: CGPoint(x: 60, y: 340)),
            ],
            enemyUnitPlacements: [
                UnitPlacement(kind: .sword, position: CGPoint(x: 300, y: 340)),
                UnitPlacement(kind: .axe, position: CGPoint(x: 340, y: 340)),
                UnitPlacement(kind: .spear, position: CGPoint(x: 280, y: 300)),
            ],
        ),
        StageDefinition(
            title: "Stage ：",
            initialSwordCount: 1,
            enemySpawnIntervalTicks: 240
        ),
        StageDefinition(
            title: "Stage 2：遠距離射撃の試練",
            initialBowCount: 2,
            initialShieldCount: 1,
            initialEnemyCount: 3,
            enemySpawnIntervalTicks: 240
        ),
        StageDefinition(
            title: "Stage 3：資源採掘と回復の護り",
            oreCount: 1,
            initialMinerals: 50,
            initialWorkerCount: 1,
            initialSwordCount: 1,
            initialShieldCount: 1,
            initialCureCount: 1,
            initialEnemyCount: 2,
            enemySpawnIntervalTicks: 300
        ),
        StageDefinition(
            title: "Stage 4：挟撃突破作戦",
            oreCount: 2,
            initialMinerals: 100,
            initialWorkerCount: 2,
            initialSwordCount: 1,
            initialBowCount: 1,
            initialShieldCount: 1,
            initialEnemyCount: 4,
            enemySpawnIntervalTicks: 200
        ),
        StageDefinition(
            title: "Stage 5：横断強襲戦",
            playerBasePosition: CGPoint(x: 60, y: 400),
            campPosition: CGPoint(x: 60, y: 260),
            mineralBasePosition: CGPoint(x: 195, y: 480),
            enemyBasePosition: CGPoint(x: 330, y: 100),
            oreCount: 2,
            initialMinerals: 80,
            playerBaseHealth: 120,
            initialWorkerCount: 1,
            initialSwordCount: 1,
            initialSpearCount: 1,
            initialBowCount: 1,
            initialShieldCount: 1,
            enemyBaseHealth: 180,
            initialEnemyCount: 4,
            enemySpawnIntervalTicks: 180
        ),
        StageDefinition(
            title: "Final Stage：城砦攻略の総力戦",
            campPosition: CGPoint(x: 168, y: 78),
            oreCount: 3,
            initialMinerals: 150,
            playerBaseHealth: 150,
            initialWorkerCount: 3,
            initialSwordCount: 2,
            initialSpearCount: 1,
            initialBowCount: 2,
            initialShieldCount: 2,
            initialCureCount: 1,
            enemyBaseHealth: 250,
            initialEnemyCount: 5,
            enemySpawnIntervalTicks: 150
        )
    ]

    private var currentStage: StageDefinition {
        Self.stages[stageIndex]
    }

    private var playerBasePosition: CGPoint {
        currentStage.playerBasePosition
    }

    private var campPosition: CGPoint? {
        currentStage.campPosition
    }

    private var selectedProductionPosition: CGPoint? {
        switch selectedProductionSite {
        case .base:
            return playerBasePosition
        case .camp:
            return campPosition
        case nil:
            return nil
        }
    }

    private var mineralPositions: [CGPoint] {
        guard currentStage.oreCount > 0 else { return [] }
        let base = currentStage.mineralBasePosition
        return (0..<currentStage.oreCount).map { i in
            CGPoint(
                x: base.x - CGFloat(i * 46),
                y: base.y + CGFloat(i * 12)
            )
        }
    }

    private var enemyBasePosition: CGPoint {
        currentStage.enemyBasePosition
    }

    private var isFinalStage: Bool {
        stageIndex == Self.stages.count - 1
    }
    private let soldierAggroRange: CGFloat = 150

    var body: some View {
        ZStack {
            if gameStatus == .title {
                stageSelectView
            } else {
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
        }
        .task {
            await runGameLoop()
        }
    }

    private var stageSelectView: some View {
        VStack(spacing: 20) {
            VStack(spacing: 8) {
                Text("MINI RTS")
                    .font(.system(size: 38, weight: .black, design: .rounded))
                    .foregroundStyle(.yellow)
                    .shadow(radius: 6)

                Text("ステージを選択して開始してください")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.7))
            }
            .padding(.top, 40)

            ScrollView {
                VStack(spacing: 12) {
                    ForEach(0..<Self.stages.count, id: \.self) { index in
                        let stage = Self.stages[index]
                        Button {
                            selectAndStartStage(index: index)
                        } label: {
                            HStack(spacing: 16) {
                                Circle()
                                    .fill(Color(red: 0.18, green: 0.24, blue: 0.19))
                                    .frame(width: 36, height: 36)
                                    .overlay(
                                        Text("\(index + 1)")
                                            .font(.system(size: 16, weight: .bold, design: .rounded))
                                            .foregroundStyle(.yellow)
                                    )

                                VStack(alignment: .leading, spacing: 6) {
                                    Text(stage.title.isEmpty ? "Stage \(index + 1)" : stage.title)
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundStyle(.white)

                                    HStack(spacing: 10) {
                                        Label("\(stage.initialMinerals)", systemImage: "diamond.fill")
                                        Label("\(stage.effectiveWorkerCount)", systemImage: "wrench.fill")
                                        Label("\(stage.totalInitialCombatUnits)", systemImage: "person.fill")
                                        Label("\(stage.oreCount)", systemImage: "sparkles")
                                    }
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundStyle(.white.opacity(0.55))
                                }

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(.yellow.opacity(0.8))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 14)
                            .background(Color(red: 0.12, green: 0.16, blue: 0.13))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.08), lineWidth: 1)
                            )
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 0.08, green: 0.11, blue: 0.09))
    }

    private var hud: some View {
        HStack(spacing: 10) {
            Button {
                gameStatus = .title
            } label: {
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.yellow)
                    .padding(6)
                    .background(Color.white.opacity(0.12), in: Circle())
            }

            Label(currentStage.title, systemImage: "flag.checkered")
            Label("Minerals: \(minerals)", systemImage: "diamond.fill")
        }
        .font(.system(size: 13, weight: .semibold, design: .rounded))
        .foregroundStyle(.white)
        .padding(.horizontal, 12)
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

                gameObjects(scale: scale, xOffset: xOffset, yOffset: yOffset, viewSize: proxy.size)
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

    private func gameObjects(scale: CGFloat, xOffset: CGFloat, yOffset: CGFloat, viewSize: CGSize) -> some View {
        ZStack {
            structure(
                title: "HQ",
                systemImage: "house.fill",
                color: .cyan,
                health: baseHealth,
                maxHealth: currentStage.playerBaseHealth,
                isSelected: selectedProductionSite == .base
            )
            .position(screenPoint(playerBasePosition, scale: scale, xOffset: xOffset, yOffset: yOffset))

            if let campPos = campPosition {
                structure(
                    title: "Camp",
                    systemImage: "tent.fill",
                    color: .green,
                    health: 100,
                    maxHealth: 100,
                    isSelected: selectedProductionSite == .camp
                )
                .position(screenPoint(campPos, scale: scale, xOffset: xOffset, yOffset: yOffset))
            }

            ForEach(0..<mineralPositions.count, id: \.self) { index in
                resourceNode
                    .position(screenPoint(mineralPositions[index], scale: scale, xOffset: xOffset, yOffset: yOffset))
            }

            structure(
                title: "Enemy",
                systemImage: "bolt.fill",
                color: .red,
                health: max(enemyBaseHealth, 0),
                maxHealth: currentStage.enemyBaseHealth
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

            if let productionPosition = selectedProductionPosition {
                productionMenu
                    .position(
                        productionMenuScreenPosition(
                            for: productionPosition,
                            scale: scale,
                            xOffset: xOffset,
                            yOffset: yOffset,
                            viewSize: viewSize
                        )
                    )
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
        HStack(spacing: 8) {
            Button {
                selectedProductionSite = nil
                selectedUnitIDs = Set(units.map(\.id))
            } label: {
                Label("All", systemImage: "scope")
            }
            .disabled(gameStatus != .playing)

            Button {
                selectedUnitIDs.removeAll()
                selectedProductionSite = nil
            } label: {
                Label("Clear", systemImage: "xmark.circle")
            }
            .disabled(gameStatus != .playing || (selectedUnitIDs.isEmpty && selectedProductionSite == nil))

            Spacer()

            Button {
                resetStage()
            } label: {
                Label("Retry", systemImage: "arrow.clockwise")
            }
            .disabled(gameStatus != .playing)
        }
        .font(.system(size: 12, weight: .semibold))
        .buttonStyle(.borderedProminent)
        .controlSize(.small)
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .background(Color(red: 0.12, green: 0.16, blue: 0.13))
    }

    private func productionMenuScreenPosition(
        for productionPosition: CGPoint,
        scale: CGFloat,
        xOffset: CGFloat,
        yOffset: CGFloat,
        viewSize: CGSize
    ) -> CGPoint {
        let menuWidth: CGFloat = 250
        let menuHeight: CGFloat = 100
        let halfWidth = menuWidth / 2
        let halfHeight = menuHeight / 2
        let verticalOffset: CGFloat = 92 * scale
        let sitePoint = screenPoint(productionPosition, scale: scale, xOffset: xOffset, yOffset: yOffset)
        let preferredY = sitePoint.y + verticalOffset
        let fallbackY = sitePoint.y - verticalOffset
        let unclampedY = preferredY + halfHeight <= viewSize.height ? preferredY : fallbackY

        return CGPoint(
            x: min(max(sitePoint.x, halfWidth), viewSize.width - halfWidth),
            y: min(max(unclampedY, halfHeight), viewSize.height - halfHeight)
        )
    }

    private var productionMenu: some View {
        VStack(spacing: 6) {
            HStack(spacing: 6) {
                trainButton(kind: .worker, cost: 25)
                trainButton(kind: .sword, cost: 35)
                trainButton(kind: .spear, cost: 35)
                trainButton(kind: .axe, cost: 35)
            }

            HStack(spacing: 6) {
                trainButton(kind: .bow, cost: 45)
                trainButton(kind: .shield, cost: 30)
                trainButton(kind: .cure, cost: 40)
            }
        }
        .padding(8)
        .frame(width: 250, height: 100)
        .background(Color.black.opacity(0.48), in: RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.white.opacity(0.14), lineWidth: 1)
        )
    }

    @ViewBuilder
    private func trainButton(kind: UnitKind, cost: Int) -> some View {
        Button {
            trainUnit(kind: kind, cost: cost)
        } label: {
            HStack(spacing: 4) {
                Image(systemName: kind.systemImage)
                    .font(.system(size: 10, weight: .bold))
                Text("\(cost)")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
            }
            .frame(width: 34, height: 22)
        }
        .disabled(gameStatus != .playing || minerals < cost || selectedProductionSite == nil)
        .buttonStyle(.borderedProminent)
        .tint(kind.color)
        .controlSize(.mini)
        .accessibilityLabel("Train \(kind.displayName)")
    }

    private var resultOverlay: some View {
        let didWin = gameStatus == .stageClear || gameStatus == .allClear

        return VStack(spacing: 12) {
            Image(systemName: didWin ? "crown.fill" : "xmark.octagon.fill")
                .font(.system(size: 42, weight: .bold))
                .foregroundStyle(didWin ? .yellow : .red)

            Text(resultTitle)
                .font(.system(size: 34, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)

            Text(resultMessage)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white.opacity(0.78))

            VStack(spacing: 10) {
                HStack(spacing: 10) {
                    Button {
                        resetStage()
                    } label: {
                        Label("Retry", systemImage: "arrow.clockwise")
                            .font(.system(size: 16, weight: .bold))
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)

                    if gameStatus == .stageClear {
                        Button {
                            advanceStage()
                        } label: {
                            Label("Next", systemImage: "arrow.right")
                                .font(.system(size: 16, weight: .bold))
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                    }
                }

                Button {
                    gameStatus = .title
                } label: {
                    Label("ステージ選択に戻る", systemImage: "list.bullet")
                        .font(.system(size: 15, weight: .bold))
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
                .tint(.yellow)
            }
            .padding(.top, 10)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.opacity(0.62))
    }

    private var resultTitle: String {
        switch gameStatus {
        case .title, .playing:
            return ""
        case .stageClear:
            return "STAGE CLEAR"
        case .allClear:
            return "ALL CLEAR"
        case .gameOver:
            return "GAME OVER"
        }
    }

    private var resultMessage: String {
        switch gameStatus {
        case .title, .playing:
            return ""
        case .stageClear:
            return "\(currentStage.title) completed"
        case .allClear:
            return "All enemy bases destroyed"
        case .gameOver:
            return "Your base was destroyed"
        }
    }

    private func unitView(_ unit: RTSUnit) -> some View {
        let isSelected = selectedUnitIDs.contains(unit.id)

        return ZStack {
            unitTriangle(size: 36, color: isSelected ? .yellow : .clear, lineWidth: 4)

            unitTriangle(size: 26, color: unit.kind.color)
                .shadow(radius: 3, y: 2)

            Image(systemName: unit.kind.systemImage)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(.white)

            unitHealthBar(unit, tint: unit.kind.color)
                .offset(y: 24)
        }
        .rotationEffect(.radians(unit.facing - .pi / 2))
    }

    private func enemyUnitView(_ unit: RTSUnit) -> some View {
        ZStack {
            unitTriangle(size: 34, color: Color.red.opacity(0.45), lineWidth: 3)

            unitTriangle(size: 24, color: .red)
                .shadow(radius: 3, y: 2)

            Image(systemName: unit.kind.systemImage)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.white)

            unitHealthBar(unit, tint: .red)
                .offset(y: 23)
        }
        .rotationEffect(.radians(unit.facing - .pi / 2))
    }

    private func unitTriangle(size: CGFloat, color: Color, lineWidth: CGFloat? = nil) -> some View {
        let path = Path { path in
            path.move(to: CGPoint(x: size / 2, y: 0))
            path.addLine(to: CGPoint(x: size, y: size * 0.8))
            path.addLine(to: CGPoint(x: 0, y: size * 0.8))
            path.closeSubpath()
        }

        return Group {
            if let lineWidth {
                path.stroke(color, lineWidth: lineWidth)
            } else {
                path.fill(color)
            }
        }
        .frame(width: size, height: size * 0.8)
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
        maxHealth: Int,
        isSelected: Bool = false
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
        .padding(5)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isSelected ? Color.yellow : Color.clear, lineWidth: 3)
        )
    }

    private func handleTap(at point: CGPoint) {
        let boardPoint = point
        guard gameStatus == .playing else { return }
        guard boardPoint.x >= 0, boardPoint.x <= 390, boardPoint.y >= 0, boardPoint.y <= 520 else { return }

        if boardPoint.distance(to: playerBasePosition) < 44 {
            selectProductionSite(.base)
            return
        }

        if let campPos = campPosition, boardPoint.distance(to: campPos) < 44 {
            selectProductionSite(.camp)
            return
        }

        guard !selectedUnitIDs.isEmpty else { return }
        selectedProductionSite = nil

        for index in units.indices where selectedUnitIDs.contains(units[index].id) {
            let offset = formationOffset(for: index)
            units[index].target = CGPoint(
                x: min(max(boardPoint.x + offset.width, 18), 372),
                y: min(max(boardPoint.y + offset.height, 18), 502)
            )
        }
    }

    private func toggleSelection(for id: RTSUnit.ID) {
        guard gameStatus == .playing else { return }
        selectedProductionSite = nil

        if selectedUnitIDs.contains(id) {
            selectedUnitIDs.remove(id)
        } else {
            selectedUnitIDs.insert(id)
        }
    }

    private func selectProductionSite(_ site: ProductionSite) {
        selectedProductionSite = site
        selectedUnitIDs.removeAll()
    }

    private func trainUnit(kind: UnitKind, cost: Int) {
        guard gameStatus == .playing,
              minerals >= cost,
              let productionPosition = selectedProductionPosition else { return }

        minerals -= cost
        units.append(
            RTSUnit(
                kind: kind,
                position: spawnPosition(near: productionPosition)
            )
        )
    }

    private func spawnPosition(near position: CGPoint) -> CGPoint {
        let spawnIndex = units.count % 4
        let offsets = [
            CGSize(width: 20, height: 36),
            CGSize(width: 44, height: 28),
            CGSize(width: -20, height: 36),
            CGSize(width: 28, height: 58)
        ]
        let offset = offsets[spawnIndex]

        return CGPoint(
            x: min(max(position.x + offset.width, 18), 372),
            y: min(max(position.y + offset.height, 18), 502)
        )
    }

    private func selectAndStartStage(index: Int) {
        stageIndex = index
        resetStage()
    }

    private func resetStage() {
        minerals = currentStage.initialMinerals
        baseHealth = currentStage.playerBaseHealth
        enemyBaseHealth = currentStage.enemyBaseHealth
        units = currentStage.makePlayerUnits(playerBasePosition: playerBasePosition)
        enemyUnits = currentStage.makeEnemyUnits(
            target: playerBasePosition,
            enemyBasePosition: enemyBasePosition
        )
        selectedUnitIDs = []
        selectedProductionSite = nil
        enemySpawnTicks = 0
        gameStatus = .playing
    }

    private func advanceStage() {
        guard stageIndex < Self.stages.count - 1 else { return }
        stageIndex += 1
        resetStage()
    }

    private func runGameLoop() async {
        let tickDuration: Duration = .milliseconds(90)
        var lastTime = ContinuousClock.now
        var accumulator: Duration = .zero

        while !Task.isCancelled {
            try? await Task.sleep(for: .milliseconds(16))
            let now = ContinuousClock.now
            accumulator += now - lastTime
            lastTime = now

            if accumulator > .seconds(1) {
                accumulator = .seconds(1)
            }

            while accumulator >= tickDuration {
                updateSimulation()
                accumulator -= tickDuration
            }
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

            if units[index].kind == .worker {
                let isNearAnyMineral = mineralPositions.contains { position in
                    units[index].position.distance(to: position) < 34
                }
                if isNearAnyMineral {
                    units[index].carryTicks += 1
                    if units[index].carryTicks >= 8 {
                        minerals += 1
                        units[index].carryTicks = 0
                    }
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

    private func calculateDamage(attacker: RTSUnit, defender: RTSUnit) -> Int {
        let baseDamage = attacker.kind.attackDamage
        guard baseDamage > 0 else { return 0 }

        var multiplier: Double = 1.0
        switch (attacker.kind, defender.kind) {
        case (.sword, .axe):
            multiplier = 1.5
        case (.spear, .sword):
            multiplier = 1.5
        case (.axe, .spear):
            multiplier = 1.5
        default:
            break
        }

        multiplier *= facingMultiplier(attacker: attacker, targetPosition: defender.position)

        return max(Int(Double(baseDamage) * multiplier), 1)
    }

    private func facingMultiplier(attacker: RTSUnit, targetPosition: CGPoint) -> Double {
        let angleToTarget = atan2(
            targetPosition.y - attacker.position.y,
            targetPosition.x - attacker.position.x
        )
        var diff = angleToTarget - attacker.facing
        diff = atan2(sin(diff), cos(diff))
        let absDiff = abs(diff)

        if absDiff <= .pi / 2 {
            return 1.0
        } else {
            return 0.5
        }
    }

    private func resolveCombat() {
        var playerDamage = Array(repeating: 0, count: units.count)
        var enemyDamage = Array(repeating: 0, count: enemyUnits.count)
        var playerHeal = Array(repeating: 0, count: units.count)

        // 1. 味方の行動
        for index in units.indices {
            let unit = units[index]

            // ヒーラー(cure)のアクション
            if unit.kind == .cure {
                for friendIndex in units.indices where friendIndex != index {
                    if unit.position.distance(to: units[friendIndex].position) < 42 {
                        playerHeal[friendIndex] += 2
                    }
                }
                continue
            }

            // 通常の攻撃
            let attackRange = unit.kind.attackRange
            if let targetIndex = nearestUnitIndex(to: unit.position, in: enemyUnits),
               unit.position.distance(to: enemyUnits[targetIndex].position) < attackRange {
                let damage = calculateDamage(attacker: unit, defender: enemyUnits[targetIndex])
                enemyDamage[targetIndex] += damage
            } else if unit.position.distance(to: enemyBasePosition) < 52, enemyBaseHealth > 0 {
                enemyBaseHealth -= unit.kind.attackDamage
            }
        }

        // 2. 敵の行動
        for index in enemyUnits.indices {
            let unit = enemyUnits[index]

            // 敵にCureがいる場合（敵ユニット同士の回復）
            if unit.kind == .cure {
                continue
            }

            let attackRange = unit.kind.attackRange
            if let targetIndex = nearestUnitIndex(to: unit.position, in: units),
               unit.position.distance(to: units[targetIndex].position) < attackRange {
                let damage = calculateDamage(attacker: unit, defender: units[targetIndex])
                playerDamage[targetIndex] += damage
            } else if unit.position.distance(to: playerBasePosition) < 52, baseHealth > 0 {
                baseHealth -= enemyUnits[index].kind.attackDamage
            }
        }

        // 3. ダメージと回復の適用
        for index in units.indices {
            let maxHealth = units[index].kind.maxHealth
            let nextHealth = units[index].health - playerDamage[index] + playerHeal[index]
            units[index].health = min(max(nextHealth, 0), maxHealth)
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
            gameStatus = isFinalStage ? .allClear : .stageClear
        } else if baseHealth <= 0 {
            baseHealth = 0
            gameStatus = .gameOver
        }
    }

    private func spawnEnemySoldierIfNeeded() {
        guard enemyBaseHealth > 0 else { return }

        enemySpawnTicks += 1
        guard enemySpawnTicks >= currentStage.enemySpawnIntervalTicks else { return }

        enemySpawnTicks = 0
        let spawnOffset = CGFloat((enemyUnits.count % 3) * 20 - 20)
        
        let chosenEnemy = currentStage.enemySpawnPool.randomElement() ?? .sword
        
        enemyUnits.append(
            RTSUnit(
                kind: chosenEnemy,
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
        unit.facing = atan2(dy, dx)
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

private struct UnitPlacement {
    let kind: UnitKind
    let position: CGPoint
}

private struct StageDefinition {
    let title: String

    var playerBasePosition: CGPoint = CGPoint(x: 72, y: 72)
    var campPosition: CGPoint? = nil
    var mineralBasePosition: CGPoint = CGPoint(x: 278, y: 130)
    var enemyBasePosition: CGPoint = CGPoint(x: 314, y: 410)

    var oreCount: Int = 0
    var initialMinerals: Int = 0
    var playerBaseHealth: Int = 100
    var enemyBaseHealth: Int = 100
    var enemySpawnIntervalTicks: Int = 99999
    var enemySpawnPool: [UnitKind] = [.sword]

    var playerUnitPlacements: [UnitPlacement]? = nil
    var enemyUnitPlacements: [UnitPlacement]? = nil

    var initialWorkerCount: Int = 0
    var initialSwordCount: Int = 0
    var initialSpearCount: Int = 0
    var initialAxeCount: Int = 0
    var initialBowCount: Int = 0
    var initialShieldCount: Int = 0
    var initialCureCount: Int = 0
    var initialEnemyCount: Int = 0

    init(
        title: String,
        playerBasePosition: CGPoint = CGPoint(x: 72, y: 72),
        campPosition: CGPoint? = nil,
        mineralBasePosition: CGPoint = CGPoint(x: 278, y: 130),
        enemyBasePosition: CGPoint = CGPoint(x: 314, y: 410),
        oreCount: Int = 0,
        initialMinerals: Int = 0,
        playerBaseHealth: Int = 100,
        initialWorkerCount: Int = 0,
        initialSwordCount: Int = 0,
        initialSpearCount: Int = 0,
        initialAxeCount: Int = 0,
        initialBowCount: Int = 0,
        initialShieldCount: Int = 0,
        initialCureCount: Int = 0,
        enemyBaseHealth: Int = 100,
        initialEnemyCount: Int = 0,
        enemySpawnIntervalTicks: Int = 99999,
        enemySpawnPool: [UnitKind] = [.sword],
        playerUnitPlacements: [UnitPlacement]? = nil,
        enemyUnitPlacements: [UnitPlacement]? = nil
    ) {
        self.title = title
        self.playerBasePosition = playerBasePosition
        self.campPosition = campPosition
        self.mineralBasePosition = mineralBasePosition
        self.enemyBasePosition = enemyBasePosition
        self.oreCount = oreCount
        self.initialMinerals = initialMinerals
        self.playerBaseHealth = playerBaseHealth
        self.initialWorkerCount = initialWorkerCount
        self.initialSwordCount = initialSwordCount
        self.initialSpearCount = initialSpearCount
        self.initialAxeCount = initialAxeCount
        self.initialBowCount = initialBowCount
        self.initialShieldCount = initialShieldCount
        self.initialCureCount = initialCureCount
        self.enemyBaseHealth = enemyBaseHealth
        self.initialEnemyCount = initialEnemyCount
        self.enemySpawnIntervalTicks = enemySpawnIntervalTicks
        self.enemySpawnPool = enemySpawnPool
        self.playerUnitPlacements = playerUnitPlacements
        self.enemyUnitPlacements = enemyUnitPlacements
    }

    var totalInitialCombatUnits: Int {
        if let placements = playerUnitPlacements {
            return placements.filter { $0.kind != .worker }.count
        }
        return initialSwordCount + initialSpearCount + initialAxeCount + initialBowCount + initialShieldCount + initialCureCount
    }

    var effectiveWorkerCount: Int {
        if let placements = playerUnitPlacements {
            return placements.filter { $0.kind == .worker }.count
        }
        return initialWorkerCount
    }

    func makeEnemyUnits(target: CGPoint, enemyBasePosition: CGPoint) -> [RTSUnit] {
        if let placements = enemyUnitPlacements {
            return placements.map { placement in
                RTSUnit(kind: placement.kind, position: placement.position, target: target)
            }
        }

        return (0..<initialEnemyCount).map { index in
            let column = index % 3 - 1
            let row = index / 3
            let position = CGPoint(
                x: enemyBasePosition.x + CGFloat(column * 26),
                y: enemyBasePosition.y - 40 - CGFloat(row * 24)
            )

            let kind = enemySpawnPool[index % enemySpawnPool.count]
            return RTSUnit(
                kind: kind,
                position: position,
                target: target
            )
        }
    }

    func makePlayerUnits(playerBasePosition: CGPoint) -> [RTSUnit] {
        if let placements = playerUnitPlacements {
            return placements.map { placement in
                RTSUnit(kind: placement.kind, position: placement.position)
            }
        }

        var playerUnits: [RTSUnit] = []
        var index = 0
        func spawnUnits(kind: UnitKind, count: Int, yOffsetBase: CGFloat) {
            for _ in 0..<count {
                let xOffset = CGFloat(24 + (index % 3) * 30)
                let yOffset = yOffsetBase + CGFloat((index / 3) * 24)
                playerUnits.append(
                    RTSUnit(
                        kind: kind,
                        position: CGPoint(x: playerBasePosition.x + xOffset, y: playerBasePosition.y + yOffset)
                    )
                )
                index += 1
            }
        }

        spawnUnits(kind: .worker, count: initialWorkerCount, yOffsetBase: 110)
        spawnUnits(kind: .shield, count: initialShieldCount, yOffsetBase: 180)
        spawnUnits(kind: .sword, count: initialSwordCount, yOffsetBase: 180)
        spawnUnits(kind: .spear, count: initialSpearCount, yOffsetBase: 180)
        spawnUnits(kind: .axe, count: initialAxeCount, yOffsetBase: 180)
        spawnUnits(kind: .bow, count: initialBowCount, yOffsetBase: 180)
        spawnUnits(kind: .cure, count: initialCureCount, yOffsetBase: 180)

        return playerUnits
    }
}

private struct RTSUnit: Identifiable {
    let id = UUID()
    let kind: UnitKind
    var position: CGPoint
    var target: CGPoint
    var health: Int
    var carryTicks = 0
    var facing: CGFloat = .pi / 2

    init(kind: UnitKind, position: CGPoint, target: CGPoint? = nil) {
        self.kind = kind
        self.position = position
        self.target = target ?? position
        self.health = kind.maxHealth
        if let target {
            self.facing = atan2(target.y - position.y, target.x - position.x)
        }
    }
}

private enum UnitKind {
    case worker
    case sword
    case spear
    case axe
    case bow
    case shield
    case cure

    var displayName: String {
        switch self {
        case .worker: return "Worker"
        case .sword: return "Sword"
        case .spear: return "Spear"
        case .axe: return "Axe"
        case .bow: return "Bow"
        case .shield: return "Shield"
        case .cure: return "Cure"
        }
    }

    var color: Color {
        switch self {
        case .worker: return .blue
        case .sword: return .red
        case .spear: return .orange
        case .axe: return .purple
        case .bow: return .yellow
        case .shield: return .gray
        case .cure: return .pink
        }
    }

    var systemImage: String {
        switch self {
        case .worker: return "wrench.fill"
        case .sword: return "hand.raised.bended.fill"
        case .spear: return "arrow.up.forward.circle.fill"
        case .axe: return "scissors"
        case .bow: return "scope"
        case .shield: return "shield.fill"
        case .cure: return "heart.fill"
        }
    }

    var speed: CGFloat {
        switch self {
        case .worker: return 2.1
        case .sword: return 2.5
        case .spear: return 2.4
        case .axe: return 2.3
        case .bow: return 2.6
        case .shield: return 1.8
        case .cure: return 2.2
        }
    }

    var maxHealth: Int {
        switch self {
        case .worker: return 18
        case .sword: return 26
        case .spear: return 24
        case .axe: return 30
        case .bow: return 18
        case .shield: return 50
        case .cure: return 20
        }
    }

    var attackDamage: Int {
        switch self {
        case .worker: return 0
        case .sword: return 3
        case .spear: return 3
        case .axe: return 4
        case .bow: return 2
        case .shield: return 0
        case .cure: return 0
        }
    }

    var attackRange: CGFloat {
        switch self {
        case .bow: return 120.0
        default: return 42.0
        }
    }
}

private enum GameStatus {
    case title
    case playing
    case stageClear
    case allClear
    case gameOver
}

private enum ProductionSite {
    case base
    case camp
}

private extension CGPoint {
    func distance(to other: CGPoint) -> CGFloat {
        hypot(x - other.x, y - other.y)
    }
}

#Preview {
    ContentView()
}
