import 'dart:async';

import 'package:book_mingle_ui/models/book_model.dart';
import 'package:book_mingle_ui/models/user_profile_model.dart';
import 'package:book_mingle_ui/services/api_service.dart';
import 'package:book_mingle_ui/services/network_image.dart';
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

  late Timer _debounce;

  late List<Book> _searchResultBooks;

  late UserProfileResponseModel _userProfile;
  List<Book> _userBooks = [];
  final RefreshController _refreshController =
      RefreshController(initialRefresh: true);

  @override
  void initState() {
    super.initState();
    _debounce = Timer(const Duration(milliseconds: 10000), () {});
    _searchResultBooks = [];
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
                            getBooksWithoutQuery();
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
        itemCount: _userBooks.length,
        itemBuilder: (context, index) => Card(
          margin: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 10,
          ),
          child: ListTile(
            leading: CircleAvatar(
              child: CustomNetWorkImage(
                imageUrl: _userBooks[index].imageUrl,
              ),
            ),
            title: Text(_userBooks[index].title),
            subtitle: Text(
              " by ${_userBooks[index].author}",
              style: TextStyle(
                fontSize: Theme.of(context).textTheme.bodySmall?.fontSize,
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _addBookModal() async {
    TextEditingController searchController = TextEditingController();
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
              TextField(
                controller: searchController,
                onChanged: getBooks,
                decoration: const InputDecoration(
                  labelText: 'Search for a Book',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              Expanded(
                child: Builder(builder: (context) {
                  return ListView.builder(
                    itemCount: _searchResultBooks.length,
                    itemBuilder: (BuildContext context, int index) {
                      Book book = _searchResultBooks[index];
                      return ListTile(
                        title: Text(book.title),
                        onTap: () async {
                          bool isSuccess =
                              await ApiService.addBookToLibrary(book.id);
                          if (isSuccess) {
                            showAddBookToLibraryRequestMessage(
                                "Book Added To Your Library Successfully");
                          } else {
                            showAddBookToLibraryRequestMessage(
                                'An Error Occurred While Creating Exchange Request');
                          }
                        },
                      );
                    },
                  );
                }),
              )
            ],
          );
        });
  }

  Future<void> getBooksWithoutQuery() async {
    if (_searchResultBooks.isEmpty) {
      List<Book> books = await ApiService.getBookList("_");

      setState(() {
        _searchResultBooks.clear();
        _searchResultBooks.addAll(books);
      });
    }
  }

  Future<void> getBooks(String query) async {
    if (_debounce.isActive) _debounce.cancel();

    _debounce = Timer(const Duration(milliseconds: 1000), () async {
      if (query.length >= 3) {
        List<Book> books = await ApiService.getBookList(query);

        setState(() {
          _searchResultBooks.clear();
          _searchResultBooks.addAll(books);
        });
      }
    });

    Scaffold.of(context).setState(() {});
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
      _userBooks = _userProfile.books;
    });
    return true;
  }
}
