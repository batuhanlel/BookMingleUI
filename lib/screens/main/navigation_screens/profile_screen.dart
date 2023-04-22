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

  late UserProfileResponseModel _userProfile;
  List<Book> _books = [];
  final RefreshController _refreshController =
      RefreshController(initialRefresh: true);

  @override
  void initState() {
    super.initState();
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
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text('Edit Profile'),
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

  Future<bool> _firstLoad() async {
    UserProfileResponseModel response = await ApiService.userProfile();
    setState(() {
      _userProfile = response;
      _books = _userProfile.books;
    });
    return true;
  }
}
