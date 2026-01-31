# Melodify - AI Agent Instructions

## Project Overview

**App Name:** Melodify  
**Technology Stack:** Flutter, Riverpod, Firebase  
**Architecture:** Modular Structure (Feature-based modules)  
**State Management:** Riverpod  
**Backend:** Firebase (Firestore, Authentication, Storage)

This is a Flutter application that follows a modular architecture with feature-based organization, using Riverpod for state management and Firebase as the backend service.

---

## Architecture Guidelines

### Modular Structure (Feature-based Architecture)

The app follows a **Modular Structure** where code is organized by features/modules rather than technical layers. Each module contains all the code related to a specific feature.

#### **Module Components**

Each feature module typically contains:

1. **Models** - Data structures for the feature
2. **Views/Screens** - UI components
3. **Providers/ViewModels** - State management and business logic
4. **Repositories** - Data access layer
5. **Widgets** - Reusable UI components specific to the feature

#### **Benefits of Modular Structure**

- **Better scalability** - Easy to add new features without affecting existing ones
- **Clear boundaries** - Each module is self-contained
- **Easier testing** - Test modules independently
- **Team collaboration** - Different developers can work on different modules
- **Code reusability** - Shared utilities and widgets across modules

#### **Example Module Structure**

```dart
// Example: Authentication Module

// Model
class User {
  final String id;
  final String email;
  final String name;
  
  User({required this.id, required this.email, required this.name});
  
  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'] as String,
    email: json['email'] as String,
    name: json['name'] as String,
  );
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'name': name,
  };
}

// Repository
class AuthRepository {
  final FirebaseAuth _auth;
  
  AuthRepository(this._auth);
  
  Future<User> signIn(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return User.fromFirebaseUser(credential.user!);
  }
}

// Provider/ViewModel
@riverpod
class AuthViewModel extends _$AuthViewModel {
  @override
  Future<User?> build() async {
    final auth = FirebaseAuth.instance;
    return auth.currentUser != null 
      ? User.fromFirebaseUser(auth.currentUser!) 
      : null;
  }
  
  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(authRepositoryProvider);
      return repository.signIn(email, password);
    });
  }
}

// View/Screen
class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authViewModelProvider);
    
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: authState.when(
        data: (user) => user != null 
          ? const Text('Logged in') 
          : const LoginForm(),
        loading: () => const CircularProgressIndicator(),
        error: (error, stack) => Text('Error: $error'),
      ),
    );
  }
}
```

### Folder Structure

```
lib/
├── main.dart                      # App entry point
├── app/                           # App-level configuration
│   ├── app.dart                   # Main app widget
│   ├── routes.dart                # Route configuration
│   └── theme.dart                 # App theme
├── core/                          # Shared/core functionality
│   ├── constants/
│   │   ├── app_constants.dart
│   │   └── firebase_constants.dart
│   ├── utils/
│   │   ├── validators.dart
│   │   ├── extensions.dart
│   │   └── helpers.dart
│   ├── widgets/                   # Shared widgets
│   │   ├── custom_button.dart
│   │   ├── loading_indicator.dart
│   │   └── error_widget.dart
│   └── services/                  # Shared services
│       ├── firebase_service.dart
│       └── storage_service.dart
├── features/                      # Feature modules
│   ├── auth/                      # Authentication module
│   │   ├── models/
│   │   │   └── user.dart
│   │   ├── providers/
│   │   │   ├── auth_provider.dart
│   │   │   └── auth_state.dart
│   │   ├── repositories/
│   │   │   └── auth_repository.dart
│   │   ├── screens/
│   │   │   ├── login_screen.dart
│   │   │   └── register_screen.dart
│   │   └── widgets/
│   │       ├── login_form.dart
│   │       └── social_login_buttons.dart
│   ├── home/                      # Home module
│   │   ├── models/
│   │   ├── providers/
│   │   ├── repositories/
│   │   ├── screens/
│   │   │   └── home_screen.dart
│   │   └── widgets/
│   ├── profile/                   # Profile module
│   │   ├── models/
│   │   ├── providers/
│   │   ├── repositories/
│   │   ├── screens/
│   │   │   └── profile_screen.dart
│   │   └── widgets/
│   └── expenses/                  # Expenses module (example)
│       ├── models/
│       │   └── expense.dart
│       ├── providers/
│       │   └── expense_provider.dart
│       ├── repositories/
│       │   └── expense_repository.dart
│       ├── screens/
│       │   ├── expense_list_screen.dart
│       │   └── add_expense_screen.dart
│       └── widgets/
│           └── expense_card.dart
└── shared/                        # Shared models/types
    └── models/
        └── result.dart
```

### Module Organization Principles

1. **Self-contained modules** - Each feature module should be as independent as possible
2. **Clear dependencies** - Modules can depend on `core/` and `shared/` but not on other feature modules
3. **Consistent structure** - All modules follow the same internal structure
4. **Separation of concerns** - UI, business logic, and data access are separated within each module

---

## Riverpod State Management

### Provider Types

#### **1. Provider** (Immutable data)
```dart
@riverpod
String appVersion(AppVersionRef ref) => '1.0.0';
```

#### **2. FutureProvider** (Async data, one-time fetch)
```dart
@riverpod
Future<User> currentUser(CurrentUserRef ref) async {
  final authService = ref.watch(authServiceProvider);
  return authService.getCurrentUser();
}
```

#### **3. StreamProvider** (Real-time data streams)
```dart
@riverpod
Stream<List<Expense>> expensesStream(ExpensesStreamRef ref) {
  final repository = ref.watch(expenseRepositoryProvider);
  return repository.watchExpenses();
}
```

#### **4. NotifierProvider** (Mutable state with methods)
```dart
@riverpod
class ExpenseNotifier extends _$ExpenseNotifier {
  @override
  List<Expense> build() => [];
  
  void addExpense(Expense expense) {
    state = [...state, expense];
  }
  
  void removeExpense(String id) {
    state = state.where((e) => e.id != id).toList();
  }
}
```

#### **5. AsyncNotifierProvider** (Async mutable state)
```dart
@riverpod
class UserProfile extends _$UserProfile {
  @override
  Future<User> build() async {
    return _fetchUserProfile();
  }
  
  Future<void> updateProfile(User updatedUser) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(userRepositoryProvider).updateUser(updatedUser);
      return updatedUser;
    });
  }
}
```

### Best Practices

1. **Use code generation** (`@riverpod` annotation with `riverpod_generator`)
2. **Keep providers focused** - single responsibility
3. **Use `ref.watch` in build methods** for reactive updates
4. **Use `ref.read` in event handlers** to avoid unnecessary rebuilds
5. **Dispose resources** in providers when needed
6. **Use `family` modifier** for parameterized providers
7. **Use `autoDispose`** for providers that should clean up when not used

```dart
// Family example - provider with parameters
@riverpod
Future<Expense> expense(ExpenseRef ref, String expenseId) async {
  final repository = ref.watch(expenseRepositoryProvider);
  return repository.getExpenseById(expenseId);
}

// AutoDispose example
@riverpod
class TempData extends _$TempData {
  @override
  String build() => '';
  
  void updateData(String data) => state = data;
}
```

### Dependency Injection

Use Riverpod for dependency injection:

```dart
// Service provider
@riverpod
FirebaseFirestore firestore(FirestoreRef ref) => FirebaseFirestore.instance;

// Repository provider that depends on service
@riverpod
ExpenseRepository expenseRepository(ExpenseRepositoryRef ref) {
  final firestore = ref.watch(firestoreProvider);
  return ExpenseRepository(firestore);
}

// ViewModel that depends on repository
@riverpod
class ExpenseViewModel extends _$ExpenseViewModel {
  @override
  Future<List<Expense>> build() async {
    final repository = ref.watch(expenseRepositoryProvider);
    return repository.getAllExpenses();
  }
}
```

---

## Firebase Integration

### Authentication

```dart
@riverpod
class AuthViewModel extends _$AuthViewModel {
  @override
  Future<User?> build() async {
    final auth = FirebaseAuth.instance;
    return auth.currentUser != null 
      ? User.fromFirebaseUser(auth.currentUser!) 
      : null;
  }
  
  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final credential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);
      return User.fromFirebaseUser(credential.user!);
    });
  }
  
  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    state = const AsyncValue.data(null);
  }
}
```

### Firestore Operations

#### **Create**
```dart
Future<void> addExpense(Expense expense) async {
  final firestore = FirebaseFirestore.instance;
  await firestore.collection('expenses').add(expense.toJson());
}
```

#### **Read (One-time)**
```dart
Future<List<Expense>> getExpenses() async {
  final snapshot = await FirebaseFirestore.instance
    .collection('expenses')
    .get();
  return snapshot.docs.map((doc) => Expense.fromJson(doc.data())).toList();
}
```

#### **Read (Real-time)**
```dart
Stream<List<Expense>> watchExpenses() {
  return FirebaseFirestore.instance
    .collection('expenses')
    .snapshots()
    .map((snapshot) => snapshot.docs
      .map((doc) => Expense.fromJson(doc.data()))
      .toList());
}
```

#### **Update**
```dart
Future<void> updateExpense(String id, Expense expense) async {
  await FirebaseFirestore.instance
    .collection('expenses')
    .doc(id)
    .update(expense.toJson());
}
```

#### **Delete**
```dart
Future<void> deleteExpense(String id) async {
  await FirebaseFirestore.instance
    .collection('expenses')
    .doc(id)
    .delete();
}
```

### Error Handling

Always handle Firebase errors properly:

```dart
Future<void> performFirebaseOperation() async {
  try {
    // Firebase operation
  } on FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found') {
      throw Exception('No user found for that email.');
    } else if (e.code == 'wrong-password') {
      throw Exception('Wrong password provided.');
    }
  } on FirebaseException catch (e) {
    throw Exception('Firebase error: ${e.message}');
  } catch (e) {
    throw Exception('Unexpected error: $e');
  }
}
```

### Repository Pattern

Encapsulate Firebase operations in repositories:

```dart
class ExpenseRepository {
  final FirebaseFirestore _firestore;
  
  ExpenseRepository(this._firestore);
  
  Future<void> addExpense(Expense expense) async {
    await _firestore.collection('expenses').add(expense.toJson());
  }
  
  Stream<List<Expense>> watchExpenses(String userId) {
    return _firestore
      .collection('expenses')
      .where('userId', isEqualTo: userId)
      .snapshots()
      .map((snapshot) => snapshot.docs
        .map((doc) => Expense.fromJson({...doc.data(), 'id': doc.id}))
        .toList());
  }
}
```

---

## Code Organization

### File Naming Conventions

- **Files:** `snake_case.dart` (e.g., `home_screen.dart`, `user_repository.dart`)
- **Classes:** `PascalCase` (e.g., `HomeScreen`, `UserRepository`)
- **Variables/Functions:** `camelCase` (e.g., `userName`, `fetchUserData()`)
- **Constants:** `lowerCamelCase` or `SCREAMING_SNAKE_CASE` for compile-time constants

### Import Organization

Order imports as follows:

```dart
// 1. Dart imports
import 'dart:async';
import 'dart:convert';

// 2. Flutter imports
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 3. Package imports
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// 4. Relative imports
import '../models/user.dart';
import '../repositories/user_repository.dart';
```

---

## Best Practices

### Error Handling

1. **Use AsyncValue for async operations**
```dart
final userState = ref.watch(userProvider);
userState.when(
  data: (user) => Text(user.name),
  loading: () => CircularProgressIndicator(),
  error: (error, stack) => Text('Error: $error'),
);
```

2. **Show user-friendly error messages**
3. **Log errors for debugging** (use Firebase Crashlytics in production)

### Null Safety

- Always use null-safe types
- Use `late` keyword sparingly and only when guaranteed initialization
- Prefer `?.` and `??` operators over explicit null checks

### Async Operations

1. **Use async/await** for better readability
2. **Handle loading states** in UI
3. **Cancel operations** when widgets are disposed (use `ref.onDispose`)

```dart
@override
Future<void> build() async {
  final cancelToken = CancelToken();
  
  ref.onDispose(() {
    cancelToken.cancel();
  });
  
  // Use cancelToken in operations
}
```

### Performance Optimization

1. **Use `const` constructors** wherever possible
2. **Avoid rebuilding entire widget trees** - use `Consumer` or `ref.watch` selectively
3. **Implement pagination** for large lists from Firebase
4. **Cache data** when appropriate using Riverpod's built-in caching
5. **Use `select` to watch specific properties**

```dart
// Instead of watching entire object
final userName = ref.watch(userProvider.select((user) => user.name));
```

### Testing Guidelines

1. **Unit test ViewModels** - test business logic independently
2. **Mock repositories** for ViewModel tests
3. **Widget tests** for Views
4. **Integration tests** for critical user flows

```dart
// Example ViewModel test
test('should add expense to state', () async {
  final container = ProviderContainer(
    overrides: [
      expenseRepositoryProvider.overrideWithValue(mockRepository),
    ],
  );
  
  final viewModel = container.read(expenseViewModelProvider.notifier);
  await viewModel.addExpense(testExpense);
  
  expect(container.read(expenseViewModelProvider).value, contains(testExpense));
});
```

---

## Common Patterns

### Loading State Pattern

```dart
class MyScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(dataProvider);
    
    return asyncData.when(
      data: (data) => DataWidget(data),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => ErrorWidget(error.toString()),
    );
  }
}
```

### Form Validation Pattern

```dart
@riverpod
class LoginForm extends _$LoginForm {
  @override
  LoginFormState build() => LoginFormState();
  
  void updateEmail(String email) {
    state = state.copyWith(
      email: email,
      emailError: _validateEmail(email),
    );
  }
  
  String? _validateEmail(String email) {
    if (email.isEmpty) return 'Email is required';
    if (!email.contains('@')) return 'Invalid email';
    return null;
  }
  
  bool get isValid => 
    state.emailError == null && 
    state.passwordError == null;
}
```

### Navigation Pattern

```dart
// Use GoRouter or similar with Riverpod
@riverpod
GoRouter router(RouterRef ref) {
  final authState = ref.watch(authViewModelProvider);
  
  return GoRouter(
    redirect: (context, state) {
      final isLoggedIn = authState.value != null;
      final isLoginRoute = state.location == '/login';
      
      if (!isLoggedIn && !isLoginRoute) return '/login';
      if (isLoggedIn && isLoginRoute) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => LoginScreen()),
      GoRoute(path: '/home', builder: (_, __) => HomeScreen()),
    ],
  );
}
```

---

## Firebase Security Considerations

1. **Never expose API keys** in version control
2. **Use Firebase Security Rules** to protect data
3. **Validate data on the server side** using Cloud Functions
4. **Implement proper authentication** before accessing data
5. **Use environment variables** for sensitive configuration

Example Security Rules:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /expenses/{expenseId} {
      allow read, write: if request.auth != null 
        && request.auth.uid == resource.data.userId;
    }
  }
}
```

---

## Code Quality Expectations

All code written for Melodify must adhere to the following quality standards:

### 1. Proper Naming

#### **Classes and Types**
- Use **PascalCase** for class names, enums, and type definitions
- Names should be descriptive and indicate purpose
- Avoid abbreviations unless widely understood

```dart
// ✅ Good
class UserAuthentication { }
class ExpenseRepository { }
enum TransactionType { income, expense }

// ❌ Bad
class ua { }
class ExpRepo { }
enum TType { inc, exp }
```

#### **Variables and Functions**
- Use **camelCase** for variables, functions, and parameters
- Names should be descriptive and self-documenting
- Boolean variables should start with `is`, `has`, `should`, or `can`

```dart
// ✅ Good
final userName = 'John Doe';
bool isAuthenticated = false;
Future<void> fetchUserData() async { }
void calculateTotalExpenses() { }

// ❌ Bad
final un = 'John Doe';
bool auth = false;
Future<void> getData() async { }
void calc() { }
```

#### **Constants**
- Use **lowerCamelCase** for runtime constants
- Use **SCREAMING_SNAKE_CASE** for compile-time constants

```dart
// ✅ Good
const int maxRetryAttempts = 3;
const String API_BASE_URL = 'https://api.example.com';
const double defaultPadding = 16.0;

// ❌ Bad
const int MAX_RETRY = 3;
const String apiurl = 'https://api.example.com';
```

#### **Files and Directories**
- Use **snake_case** for file and directory names
- File names should match the primary class they contain

```dart
// ✅ Good
user_authentication.dart  // Contains UserAuthentication class
expense_repository.dart   // Contains ExpenseRepository class

// ❌ Bad
UserAuthentication.dart
expenseRepo.dart
```

### 2. Separation of UI and Logic

**CRITICAL:** UI code and business logic must be strictly separated. Never mix business logic with UI code.

#### **UI Layer (Views/Screens/Widgets)**
- Contains ONLY presentation logic
- Handles user interactions by calling ViewModel methods
- Displays data from ViewModels/Providers
- No direct Firebase calls or business logic

```dart
// ✅ Good - UI only handles presentation
class ExpenseListScreen extends ConsumerWidget {
  const ExpenseListScreen({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expensesAsync = ref.watch(expensesProvider);
    
    return Scaffold(
      appBar: AppBar(title: const Text('Expenses')),
      body: expensesAsync.when(
        data: (expenses) => ListView.builder(
          itemCount: expenses.length,
          itemBuilder: (context, index) => ExpenseCard(expense: expenses[index]),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => ref.read(expensesProvider.notifier).addExpense(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ❌ Bad - Business logic mixed with UI
class ExpenseListScreen extends StatefulWidget {
  @override
  _ExpenseListScreenState createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  List<Expense> expenses = [];
  
  @override
  void initState() {
    super.initState();
    // ❌ Direct Firebase call in UI
    FirebaseFirestore.instance.collection('expenses').get().then((snapshot) {
      setState(() {
        expenses = snapshot.docs.map((doc) => Expense.fromJson(doc.data())).toList();
      });
    });
  }
  
  void _addExpense() {
    // ❌ Business logic in UI
    final newExpense = Expense(/* ... */);
    FirebaseFirestore.instance.collection('expenses').add(newExpense.toJson());
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(/* ... */);
  }
}
```

#### **Logic Layer (Providers/ViewModels/Repositories)**
- Contains all business logic
- Handles data operations
- Manages state
- Communicates with Firebase and other services

```dart
// ✅ Good - Logic separated in Provider
@riverpod
class ExpensesNotifier extends _$ExpensesNotifier {
  @override
  Future<List<Expense>> build() async {
    return _fetchExpenses();
  }
  
  Future<List<Expense>> _fetchExpenses() async {
    final repository = ref.read(expenseRepositoryProvider);
    return repository.getAllExpenses();
  }
  
  Future<void> addExpense(Expense expense) async {
    final repository = ref.read(expenseRepositoryProvider);
    await repository.addExpense(expense);
    // Refresh the list
    state = AsyncValue.data([...state.value ?? [], expense]);
  }
}
```

### 3. Reusable Widgets

Create reusable widgets for common UI patterns. This improves maintainability and consistency.

#### **When to Create Reusable Widgets**
- UI component used in multiple places
- Complex widget that can be extracted for clarity
- Widget with configurable behavior

#### **Widget Organization**
- **Shared widgets** → `lib/core/widgets/`
- **Feature-specific widgets** → `lib/features/[feature]/widgets/`

```dart
// ✅ Good - Reusable button widget
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final IconData? icon;
  
  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
  });
  
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon),
                const SizedBox(width: 8),
              ],
              Text(text),
            ],
          ),
    );
  }
}

// Usage across multiple screens
PrimaryButton(
  text: 'Login',
  icon: Icons.login,
  isLoading: isLoading,
  onPressed: () => _handleLogin(),
)
```

```dart
// ✅ Good - Reusable card widget
class ExpenseCard extends StatelessWidget {
  final Expense expense;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  
  const ExpenseCard({
    super.key,
    required this.expense,
    this.onTap,
    this.onDelete,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(_getCategoryIcon(expense.category)),
        ),
        title: Text(expense.title),
        subtitle: Text(expense.date.toString()),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('\$${expense.amount.toStringAsFixed(2)}'),
            if (onDelete != null)
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: onDelete,
              ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
  
  IconData _getCategoryIcon(String category) {
    // Icon logic here
    return Icons.category;
  }
}
```

#### **Reusable Widget Best Practices**
- Make widgets **configurable** with parameters
- Use **const constructors** when possible
- Provide **sensible defaults** for optional parameters
- Keep widgets **focused** on a single responsibility
- Document complex widgets with comments

### 4. Comments Where Logic is Non-Trivial

Add comments to explain **WHY**, not **WHAT**. Code should be self-documenting for simple operations.

#### **When to Add Comments**

✅ **DO comment:**
- Complex algorithms or business logic
- Non-obvious workarounds or fixes
- Important architectural decisions
- Public APIs and reusable functions
- Regular expressions or complex data transformations

❌ **DON'T comment:**
- Obvious code that's self-explanatory
- Redundant descriptions of what code does

```dart
// ✅ Good - Explains WHY
/// Calculates the user's credit score based on transaction history.
/// 
/// Uses a weighted algorithm where:
/// - Recent transactions have 60% weight
/// - Payment consistency has 30% weight
/// - Account age has 10% weight
/// 
/// This algorithm was chosen after A/B testing showed 23% better
/// prediction accuracy compared to the previous linear model.
double calculateCreditScore(List<Transaction> transactions) {
  // Sort by date descending to prioritize recent transactions
  final sortedTransactions = [...transactions]
    ..sort((a, b) => b.date.compareTo(a.date));
  
  // Take only last 90 days for recency calculation
  final recentTransactions = sortedTransactions
    .where((t) => t.date.isAfter(DateTime.now().subtract(const Duration(days: 90))))
    .toList();
  
  final recencyScore = _calculateRecencyScore(recentTransactions);
  final consistencyScore = _calculateConsistencyScore(transactions);
  final ageScore = _calculateAgeScore(transactions);
  
  // Weighted average based on A/B test results
  return (recencyScore * 0.6) + (consistencyScore * 0.3) + (ageScore * 0.1);
}

// ❌ Bad - States the obvious
// This function adds two numbers
int add(int a, int b) {
  // Return the sum of a and b
  return a + b;
}

// ✅ Good - No comment needed, code is self-explanatory
int add(int a, int b) => a + b;
```

```dart
// ✅ Good - Explains workaround
Future<void> syncUserData() async {
  // WORKAROUND: Firebase sometimes returns stale data on first read
  // after a write. Adding a small delay ensures consistency.
  // See: https://github.com/firebase/firebase-js-sdk/issues/1234
  await Future.delayed(const Duration(milliseconds: 100));
  
  final userData = await _firestore.collection('users').doc(userId).get();
  // ... rest of the code
}
```

```dart
// ✅ Good - Documents public API
/// Validates an email address according to RFC 5322 standards.
/// 
/// Returns `null` if the email is valid, otherwise returns an error message.
/// 
/// Example:
/// ```dart
/// final error = validateEmail('user@example.com');
/// if (error != null) {
///   print('Invalid email: $error');
/// }
/// ```
String? validateEmail(String email) {
  if (email.isEmpty) return 'Email is required';
  
  // Simplified RFC 5322 regex pattern
  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  
  if (!emailRegex.hasMatch(email)) {
    return 'Please enter a valid email address';
  }
  
  return null;
}
```

#### **Comment Style Guidelines**
- Use `///` for documentation comments (public APIs)
- Use `//` for inline explanations
- Keep comments concise and up-to-date
- Remove commented-out code before committing
- Use TODO comments for future improvements: `// TODO: Add pagination support`

---

## Additional Notes

- **Always use Riverpod code generation** (`riverpod_generator` and `build_runner`)
- **Run `flutter pub run build_runner watch`** during development
- **Keep ViewModels testable** - avoid direct Flutter dependencies
- **Use repositories** to abstract Firebase operations
- **Implement proper error boundaries** in the UI
- **Follow Flutter's official style guide**
- **Document complex business logic** with comments
- **Use meaningful variable and function names**

---

## Quick Reference Commands

```bash
# Generate Riverpod code
flutter pub run build_runner build --delete-conflicting-outputs

# Watch for changes (development)
flutter pub run build_runner watch

# Run tests
flutter test

# Analyze code
flutter analyze
```

---

**Last Updated:** 2026-01-31  
**Version:** 1.0
