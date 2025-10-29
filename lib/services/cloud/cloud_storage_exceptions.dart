
class CloudStorageException implements Exception {
  const CloudStorageException();
}

// C in CRUD
class CouldNotCreateTaskException implements CloudStorageException {}
class CouldNotCreateNoteException implements CloudStorageException {}

// R in CRUD
class CouldNotGetAllTasksException implements CloudStorageException {}
class CouldNotGetAllNotesException implements CloudStorageException {}

// U in CRUD
class CouldNotUpdateTaskException implements CloudStorageException {}
class CouldNotUpdateNoteException implements CloudStorageException {}

// D in CRUD
class CouldNotDeleteTaskException implements CloudStorageException {}
class CouldNotDeleteNoteException implements CloudStorageException {}
