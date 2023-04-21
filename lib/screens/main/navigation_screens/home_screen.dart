import 'package:book_mingle_ui/models/exchange_book_model.dart';
import 'package:book_mingle_ui/screens/main/search_screen.dart';
import 'package:book_mingle_ui/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  List<ExchangeBookResponseModel> _items = [];
  int _currentPage = 0;
  bool _hasNextPage = true;
  late ExchangeBookRequestModel _bookRequestModel;
  final RefreshController _refreshController =
      RefreshController(initialRefresh: true);

  @override
  void initState() {
    super.initState();
    _bookRequestModel = ExchangeBookRequestModel(page: _currentPage);
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SmartRefresher(
                controller: _refreshController,
                enablePullUp: true,
                header: const WaterDropHeader(),
                footer: const ClassicFooter(
                  loadStyle: LoadStyle.ShowWhenLoading,
                ),
                onRefresh: _onRefresh,
                onLoading: _onLoading,
                child: _buildListView(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      title: TextField(
        onTap: _navigateToSearchScreen,
        decoration: const InputDecoration(
          hintText: 'Search Book, Author, Publisher',
          suffixIcon: Icon(Icons.search),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Future<void> _onRefresh() async {
    bool isSuccessful = await _firstLoad();
    isSuccessful
        ? _refreshController.refreshCompleted()
        : _refreshController.refreshFailed();
  }

  Future<void> _onLoading() async {
    bool isSuccessful = await _loadMore();
    isSuccessful
        ? _refreshController.loadComplete()
        : _refreshController.loadNoData();
  }

  ListView _buildListView() {
    return ListView.builder(
      itemCount: _items.length,
      itemBuilder: (context, index) => GestureDetector(
        onTap: () => _bookRequestDialog(_items[index]),
        child: Card(
          margin: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 10,
          ),
          child: ListTile(
            leading: CircleAvatar(
              child: Text(index.toString()),
            ),
            title: Text(_items[index].userEmail),
            subtitle: Text(_items[index].author),
          ),
        ),
      ),
    );
  }

  void _bookRequestDialog(ExchangeBookResponseModel item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(item.title),
        content: Text(item.author),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _navigateToSearchScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return const SearchScreen();
        },
      ),
    );
  }

  Future<bool> _firstLoad() async {
    _currentPage = 0;
    _bookRequestModel.page = _currentPage;
    _hasNextPage = true;
    _refreshController.loadComplete();
    List<ExchangeBookResponseModel> response =
        await ApiService.exchangeBookRecommendation(_bookRequestModel);
    if (response.isNotEmpty) {
      setState(() {
        _items = response;
      });
      return true;
    }
    return false;
  }

  Future<bool> _loadMore() async {
    if (!_hasNextPage) {
      return false;
    }

    _currentPage++;
    _bookRequestModel.page = _currentPage;

    List<ExchangeBookResponseModel> response =
        await ApiService.exchangeBookRecommendation(_bookRequestModel);
    if (response.isNotEmpty) {
      setState(() {
        _items.addAll(response);
      });
      return true;
    }
    setState(() {
      _hasNextPage = false;
    });
    return false;
  }

  @override
  bool get wantKeepAlive => true;
}
