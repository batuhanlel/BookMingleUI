import 'package:book_mingle_ui/models/book_model.dart';
import 'package:book_mingle_ui/models/user_profile_model.dart';
import 'package:book_mingle_ui/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late Book _selectedBookForLibrary;
  late List<DropdownMenuEntry<Book>> _dropDownBooks;

  late UserProfileResponseModel _userProfile;
  List<Book> _books = [];
  final RefreshController _refreshController =
      RefreshController(initialRefresh: true);

  @override
  void initState() {
    super.initState();
    _dropDownBooks = [];
    _userProfile = UserProfileResponseModel(
      email: "",
      name: "",
      surname: "",
      bookCount: 0,
      successfulExchangeCount: 0,
      books: List.empty(),
    );
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SmartRefresher(
                controller: _refreshController,
                header: const WaterDropHeader(),
                onRefresh: _onRefresh,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: size.height * 0.02),
                    CircleAvatar(radius: size.width * 0.2),
                    SizedBox(height: size.height * 0.02),
                    Text(
                      "${_userProfile.name} ${_userProfile.surname}",
                      style: Theme.of(context).textTheme.headline5,
                    ),
                    SizedBox(height: size.height * 0.01),
                    Text(
                      _userProfile.email,
                      style: Theme.of(context).textTheme.subtitle1,
                    ),
                    SizedBox(height: size.height * 0.02),
                    _buildBookAndExchangeInfo(size),
                    SizedBox(height: size.height * 0.02),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ElevatedButton(
                          onPressed: () {},
                          child: const Text('Edit Profile'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            getBooks();
                            _addBookModal();
                          },
                          child: const Text('Add Books'),
                        ),
                      ],
                    ),
                    _buildListView(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: const Text(
        'Profile',
        style: TextStyle(color: Colors.black),
      ),
      centerTitle: false,
      backgroundColor: Colors.white,
      iconTheme: const IconThemeData(color: Colors.black),
    );
  }

  Future<void> _onRefresh() async {
    bool isSuccessful = await _firstLoad();
    isSuccessful
        ? _refreshController.refreshCompleted()
        : _refreshController.refreshFailed();
  }

  Row _buildBookAndExchangeInfo(Size size) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Column(
          children: [
            Text(
              _userProfile.bookCount.toString(),
              style: Theme.of(context).textTheme.headline6,
            ),
            SizedBox(height: size.height * 0.005),
            Text(
              'Books',
              style: Theme.of(context).textTheme.subtitle2,
            ),
          ],
        ),
        Column(
          children: [
            Text(
              _userProfile.successfulExchangeCount.toString(),
              style: Theme.of(context).textTheme.headline6,
            ),
            SizedBox(height: size.height * 0.005),
            Text(
              'Trades',
              style: Theme.of(context).textTheme.subtitle2,
            ),
          ],
        ),
      ],
    );
  }

  Expanded _buildListView() {
    return Expanded(
      child: ListView.builder(
        itemCount: _books.length,
        itemBuilder: (context, index) => Card(
          margin: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 10,
          ),
          child: ListTile(
            leading: CircleAvatar(
              child: Text(index.toString()),
            ),
            title: Text(_books[index].title),
            subtitle: Text(_books[index].author),
          ),
        ),
      ),
    );
  }

  void _addBookModal() async {
    Size size = MediaQuery.of(context).size;
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Add Books To Your Library",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                  ),
                ),
              ),
              DropdownMenu(
                dropdownMenuEntries: _dropDownBooks,
                width: size.width * 0.7,
                menuHeight: size.height * 0.3,
                label: const Text('Select a Book'),
                enableFilter: true,
                onSelected: (Book? book) {
                  setState(() {
                    _selectedBookForLibrary = book!;
                  });
                },
              ),
              SizedBox(
                height: size.height * 0.01,
              ),
              TextButton(
                  onPressed: () async {
                    bool isSuccess = await ApiService.addBookToLibrary(
                        _selectedBookForLibrary.id);
                    if (isSuccess) {
                      showAddBookToLibraryRequestMessage(
                          "Book Added To Your Library Successfully");
                    } else {
                      showAddBookToLibraryRequestMessage(
                          'An Error Occurred While Creating Exchange Request');
                    }
                  },
                  child: const Text("Add Selected Book")),
            ],
          );
        });
  }

  Future<void> getBooks() async {
    if (_dropDownBooks.isEmpty) {
      List<Book> bookList = await ApiService.getBookList();
      setState(() {
        for (Book book in bookList) {
          _dropDownBooks.add(DropdownMenuEntry(
            value: book,
            label: book.title,
          ));
        }
      });
    }
  }

  void showAddBookToLibraryRequestMessage(String message) {
    Navigator.pop(context);
    if (message.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<bool> _firstLoad() async {
    UserProfileResponseModel response = await ApiService.userProfile();
    setState(() {
      _userProfile = response;
      _books = _userProfile.books;
    });
    return true;
  }
}
