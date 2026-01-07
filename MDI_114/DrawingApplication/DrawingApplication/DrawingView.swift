import SwiftUI
import PencilKit // UIKit

struct CanvasView: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    @Binding var toolPicker: PKToolPicker
    
    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.drawingPolicy = .anyInput
        canvasView.delegate = context.coordinator
        
        let dragInteraction = UIDragInteraction(delegate: context.coordinator)
        canvasView.addInteraction(dragInteraction) 
        
        return canvasView
    }
    
    func updateUIView(_ uiView: PKCanvasView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PKCanvasViewDelegate, UIDragInteractionDelegate {
        var parent: CanvasView
        
        init(_ parent: CanvasView) {
            self.parent = parent
        }
        
        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {}
        
        func dragInteraction(
            _ interaccion: UIDragInteraction,
            itemsForBeginning session: UIDragSession
        ) -> [UIDragItem] {
            let image = parent.canvasView.drawing.image(
                from: parent.canvasView.bounds,
                scale: 2.0
            )
            
            let provider = NSItemProvider(object: image)
            return [UIDragItem(itemProvider: provider)]
        }
        
    }
}

// SwiftUI
struct DrawingView: View {
    @State private var canvasView = PKCanvasView() // UI Kit Componets
    @State private var toolPicker = PKToolPicker() // UI Kit Componets
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Is taking UI Kit Components (two) and returning Swift UI Components
                CanvasView(
                    canvasView: $canvasView,
                    toolPicker: $toolPicker
                )
                .navigationBarTitle("Drawing Pad", displayMode: .inline)
                .navigationBarItems(
                    leading: HStack() {
                        Button(action: clearDrawings) {
                            Label("Clear", systemImage: "trash")
                        }
                        .keyboardShortcut("k", modifiers: .command)
                    },
                    trailing: HStack(spacing: 20) {
                        Button(action: undoAction) {
                            Label("Undo", systemImage: "arrow.uturn.backward")
                        }
                        .keyboardShortcut("z", modifiers: .command)
                        
                        Button(action: redoAction) {
                            Label("Redo", systemImage: "arrow.uturn.forward")
                        }
                        .keyboardShortcut("z", modifiers: [.command, .shift])
                    }
                )
                .onAppear(perform: setUpToolPicker)
            }
            .ignoresSafeArea(.container, edges: .bottom)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func clearDrawings() {
        canvasView.drawing = PKDrawing()
    }
    
    private func undoAction() {
        canvasView.undoManager?.undo()
    }
    
    private func redoAction() {
        canvasView.undoManager?.redo()
    }
    
    private func setUpToolPicker() {
        DispatchQueue.main.async {
            toolPicker.setVisible(true, forFirstResponder: canvasView)
            toolPicker.addObserver(canvasView)
            canvasView.becomeFirstResponder()
        }
    }
}

#Preview {
    DrawingView()
        .previewInterfaceOrientation(.landscapeLeft)
}
