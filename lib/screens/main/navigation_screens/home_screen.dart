import 'package:book_mingle_ui/models/book_model.dart';
import 'package:book_mingle_ui/models/exchange_book_model.dart';
import 'package:book_mingle_ui/models/exchange_demand_model.dart';
import 'package:book_mingle_ui/screens/main/search_screen.dart';
import 'package:book_mingle_ui/services/api_service.dart';
import 'package:book_mingle_ui/services/network_image.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  late Book _selectedBookForExchange;
  late List<DropdownMenuEntry<Book>> dropdown;
  List<ExchangeBookResponseModel> _items = [];
  int _currentPage = 0;
  bool _hasNextPage = true;
  late ExchangeBookRequestModel _bookRequestModel;
  final RefreshController _refreshController =
      RefreshController(initialRefresh: true);

  @override
  void initState() {
    super.initState();
    dropdown = [];
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
    return Scaffold(
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SmartRefresher(
                controller: _refreshController,
                enablePullUp: false,
                header: const WaterDropHeader(),
                footer: const ClassicFooter(
                  loadStyle: LoadStyle.ShowWhenLoading,
                ),
                onRefresh: _onRefresh,
                // onLoading: _onLoading,
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
    List<Book> userBooks = await ApiService.getUserBookList();
    setState(() {
      dropdown = [];
      for (Book book in userBooks) {
        dropdown.add(DropdownMenuEntry(value: book, label: book.title));
      }
    });

    bool isSuccessful = await _firstLoad();
    isSuccessful
        ? _refreshController.refreshCompleted()
        : _refreshController.refreshFailed();
  }

  // Future<void> _onLoading() async {
  //   bool isSuccessful = await _loadMore();
  //   isSuccessful
  //       ? _refreshController.loadComplete()
  //       : _refreshController.loadNoData();
  // }

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
              child: CustomNetWorkImage(
                imageUrl: _items[index].imageUrl,
              ),
              // child: Text(index.toString()),
            ),
            title: Row(
              children: [
                Flexible(
                  child: Text(
                    _items[index].title,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Flexible(
                  child: Text(
                    " by ${_items[index].author}",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: Theme.of(context).textTheme.bodySmall?.fontSize,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
            subtitle: Text(
                "- ${_items[index].userName} ${_items[index].userSurname}"),
          ),
        ),
      ),
    );
  }

  void _bookRequestDialog(ExchangeBookResponseModel item) {
    Size size = MediaQuery.of(context).size;
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Create a Exchange Request for\n${item.title}-${item.author}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18.0,
                  ),
                ),
              ),
              DropdownMenu(
                menuHeight: size.height * 0.2,
                label: const Text("Select a Book To Exchange"),
                enableFilter: true,
                dropdownMenuEntries: dropdown,
                onSelected: (Book? book) {
                  setState(() {
                    _selectedBookForExchange = book!;
                  });
                },
              ),
              SizedBox(
                height: size.height * 0.01,
              ),
              TextButton(
                  onPressed: () async {
                    bool isSuccess = await ApiService.createExchangeRequest(
                        ExchangeDemandRequest(
                            proposedBookId: _selectedBookForExchange.id,
                            requestedUserId: item.userId,
                            requestedBookId: item.bookId));
                    if (isSuccess) {
                      showExchangeDemandRequestResultMessage(
                          'Exchange Request Created Successfully');
                    } else {
                      showExchangeDemandRequestResultMessage(
                          'An Error Occurred While Creating Exchange Request');
                    }
                  },
                  child: const Text("Create Request")),
            ],
          );
        });
  }

  void showExchangeDemandRequestResultMessage(String message) {
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
        await ApiService.exchangeBookRecommendations();
    if (response.isNotEmpty) {
      setState(() {
        _items = response;
      });
      return true;
    }
    return false;
  }

  // Future<bool> _loadMore() async {
  //   if (!_hasNextPage) {
  //     return false;
  //   }
  //
  //   _currentPage++;
  //   _bookRequestModel.page = _currentPage;
  //
  //   List<ExchangeBookResponseModel> response =
  //       await ApiService.exchangeBookRecommendation(_bookRequestModel);
  //   if (response.isNotEmpty) {
  //     setState(() {
  //       _items.addAll(response);
  //     });
  //     return true;
  //   }
  //   setState(() {
  //     _hasNextPage = false;
  //   });
  //   return false;
  // }

  @override
  bool get wantKeepAlive => true;
}
