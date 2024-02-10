import SwiftUI


struct Note: Identifiable {
    let id = UUID()
    var title: String
    var content: String
    var creationDate: Date2
    
    init(title: String, content: String, creationDate: Date = Date()) {
        self.title = title
        self.content = content
        self.creationDate = creationDate
    }
}


class NoteManager: ObservableObject {
    @Published var notes: [Note]
    
    init() {
        self.notes = [
            Note(title: "Заголовок заметки", content: "Текст заметки", creationDate: Date())
        ]
    }
    
    
    func addNote(title: String, content: String) {
        let newNote = Note(title: title, content: content)
        notes.append(newNote)
    }
    
    
    func updateNote(_ note: Note, title: String, content: String) {
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            notes[index].title = title
            notes[index].content = content
        }
    }
    

    func deleteNote(at indexSet: IndexSet) {
        notes.remove(atOffsets: indexSet)
    }
}


struct NoteListView: View {
    @ObservedObject var noteManager = NoteManager()
    @State private var showingDetail = false
    @State private var selectedNote: Note?
    
    var body: some View {
        NavigationView {
            List {
                ForEach(noteManager.notes) { note in
                    NavigationLink(destination: NoteDetailView(note: note, noteManager: noteManager)) {
                        Text(note.title)
                    }
                }
                .onDelete(perform: noteManager.deleteNote)
            }
            .navigationTitle("Заметки")
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Button(action: {
                        showingDetail = true
                    }) {
                        Image("Note free icons designed by Freepik.jpeg") // Имя вашего изображения для иконки
                    }
                }
            }
            .sheet(isPresented: $showingDetail) {
                NoteDetailView(noteManager: noteManager)
            }
        }
    }
}


struct NoteDetailView: View {
    @ObservedObject var noteManager: NoteManager
    @State private var title: String
    @State private var content: String
    
    var note: Note?
    
    init(note: Note? = nil, noteManager: NoteManager) {
        self.note = note
        self._title = State(initialValue: note?.title ?? "")
        self._content = State(initialValue: note?.content ?? "")
        self.noteManager = noteManager
    }
    
    var body: some View {
        VStack {
            TextField("Заголовок", text: $title)
                .padding()
            TextEditor(text: $content)
                .padding()
            Button(action: {
                if let note = note {
                    noteManager.updateNote(note, title: title, content: content)
                } else {
                    noteManager.addNote(title: title, content: content)
                }
            }) {
                Text("Сохранить")
            }
            .padding()
            .disabled(title.isEmpty || content.isEmpty)
        }
        .navigationTitle("Заметка")
    }
}


@main
struct NoteApp: App {
    var body: some Scene {
        WindowGroup {
            NoteListView()
        }
    }
}
