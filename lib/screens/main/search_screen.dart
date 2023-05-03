import 'dart:async';

import 'package:book_mingle_ui/models/book_model.dart';
import 'package:book_mingle_ui/models/exchange_book_model.dart';
import 'package:book_mingle_ui/models/exchange_demand_model.dart';
import 'package:book_mingle_ui/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: true);
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<ExchangeBookResponseModel> _items = [];
  int _currentPage = 0;
  bool _hasNextPage = true;
  late ExchangeBookRequestModel _bookRequestModel;
  late Timer _debounce;

  late Book _selectedBookForExchange;
  late List<DropdownMenuEntry<Book>> dropdown;

  String _selectedCategory = 'All Categories';
  String _selectedRating = '0';
  final List<String> _ratings = [
    '0',
    '1',
    '2',
  ];
  final List<String> _categories = [
    'All Categories',
    'Fiction',
    'Non-fiction',
    'Children',
    'Young Adult',
  ];

  @override
  void initState() {
    super.initState();
    dropdown = [];
    _bookRequestModel = ExchangeBookRequestModel(page: _currentPage);
    _debounce = Timer(const Duration(milliseconds: 10000), () {});
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SafeArea(
        child: SmartRefresher(
          controller: _refreshController,
          enablePullUp: true,
          enablePullDown: true,
          header: const WaterDropHeader(),
          footer: const ClassicFooter(
            loadStyle: LoadStyle.ShowWhenLoading,
          ),
          onRefresh: _onRefresh,
          onLoading: _onLoading,
          child: _buildListView(),
        ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        color: Colors.grey,
        onPressed: _navigateToHomeScreen,
      ),
      backgroundColor: Colors.white,
      title: Form(
        key: _formKey,
        child: TextFormField(
          onChanged: _onSearchTextChanged,
          decoration: InputDecoration(
            hintText: 'Search Book, Author, Publisher',
            suffixIcon: IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: _openFilterMenu,
            ),
            border: InputBorder.none,
          ),
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

    userBooks.isNotEmpty
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
      itemBuilder: (context, index) => Card(
        margin: const EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 10,
        ),
        child: ListTile(
          onTap: () => _bookRequestDialog(_items[index]),
          leading: CircleAvatar(
            child: Text(index.toString()),
          ),
          title: Text(_items[index].title),
          subtitle: Text(_items[index].author),
        ),
      ),
    );
  }

  void _navigateToHomeScreen() {
    Navigator.of(context).pop();
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
                width: size.width * 0.7,
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

  void _openFilterMenu() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Expanded(
          child: Container(
            height: 400.0,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Filter Books',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
                DropdownButton<String>(
                  value: _selectedCategory,
                  hint: Text('Select Category'),
                  items: _categories.map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      _selectedCategory = value!;
                    });
                  },
                ),
                SizedBox(height: 16.0),
                DropdownButton<String>(
                  value: _selectedRating,
                  hint: Text('Select Rating'),
                  items: _ratings.map((String rating) {
                    return DropdownMenuItem<String>(
                      value: rating,
                      child: Text(rating),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    setState(() {
                      _selectedRating = value!;
                    });
                  },
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    // Apply filter logic here
                    Navigator.pop(context);
                  },
                  child: Text('Apply Filter'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<bool> _firstLoad() async {
    _formKey.currentState?.save();
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

  void _onSearchTextChanged(String newText) {
    setState(() {
      _bookRequestModel.searchText = newText;
    });
    if (_debounce?.isActive ?? false) _debounce.cancel();
    _debounce = Timer(const Duration(milliseconds: 1000), () async {
      if (newText.length >= 3) {
        await _firstLoad();
      }
    });
  }
}
