import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';
import 'package:xpertexams/Controllers/Auth/SignIn/SignInController.dart';
import 'package:xpertexams/Controllers/Course/CourseController.dart';
import 'package:xpertexams/Core/BottomBar/ButtomBar.dart';
import 'package:xpertexams/Models/VideoModel.dart';
import 'package:xpertexams/Routes/AppRoute.dart';
import 'package:xpertexams/Views/tracks/video_player_view.dart';

class VideoWithContext {
  final Video video;
  final int courseId;
  final int trackId;
  final String courseName;
  final String trackName;

  VideoWithContext({
    required this.video,
    required this.courseId,
    required this.trackId,
    required this.courseName,
    required this.trackName,
  });
}

class TrackAllVideosPage extends StatefulWidget {
  const TrackAllVideosPage({super.key});

  @override
  State<TrackAllVideosPage> createState() => _TrackAllVideosPageState();
}

class _TrackAllVideosPageState extends State<TrackAllVideosPage>
    with TickerProviderStateMixin {
  List<VideoWithContext> allVideos = [];
  List<VideoWithContext> filteredVideos = [];
  bool isLoading = true;
  String searchQuery = '';
  String selectedFilter = 'All'; // All, Completed, Incomplete
  late TabController _tabController;
  int? _userId;

  // Animation controllers
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _setupAnimations();
    _loadUserVideos();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadUserVideos() async {
    try {
      setState(() => isLoading = true);
      
      await _loadUserId();
      if (_userId == null) {
        _showErrorSnack("Please log in to view videos");
        setState(() => isLoading = false);
        return;
      }

      final signInController = Get.find<SignInController>();
      final userData = signInController.user.value;
      
      if (userData?.tracks == null || userData!.tracks.isEmpty) {
        setState(() => isLoading = false);
        return;
      }

      allVideos.clear();

      // Load videos from all user's tracks
      for (final track in userData.tracks) {
        if (track.courses.isEmpty) continue;

        for (final course in track.courses) {
          if (course.video.isEmpty) continue;

          for (final video in course.video) {
            try {
             

              await video.loadCompletionStatus(userId: _userId);
              
              if (video.url?.isNotEmpty == true) {
                allVideos.add(VideoWithContext(
                  video: video,
                  courseId: course.id!,
                  trackId: track.id!,
                  courseName: course.title,
                  trackName: track.name,
                ));
              }
            } catch (e) {
              debugPrint('Error loading video ${video.title}: $e');
            }
          }
        }
      }

      _applyFilters();
      _fadeController.forward();
    } catch (e) {
      _showErrorSnack("Error loading videos: ${e.toString()}");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _loadUserId() async {
    try {
      final signInController = Get.find<SignInController>();
      final userData = signInController.user.value;
      if (userData?.id != null) {
        _userId = userData!.id;
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      _userId = prefs.getInt('user_id');
    } catch (e) {
      debugPrint('Error loading user ID: $e');
    }
  }

  void _applyFilters() {
    filteredVideos = allVideos.where((videoContext) {
      final video = videoContext.video;
      
      // Apply search filter
      final matchesSearch = searchQuery.isEmpty ||
          video.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          videoContext.trackName.toLowerCase().contains(searchQuery.toLowerCase()) ||
          videoContext.courseName.toLowerCase().contains(searchQuery.toLowerCase());

      // Apply completion filter
      final matchesCompletion = selectedFilter == 'All' ||
          (selectedFilter == 'Completed' && video.isCompleted) ||
          (selectedFilter == 'Incomplete' && !video.isCompleted);

      return matchesSearch && matchesCompletion;
    }).toList();

    // Sort by completion status and then by title
    filteredVideos.sort((a, b) {
      if (a.video.isCompleted != b.video.isCompleted) {
        return a.video.isCompleted ? 1 : -1; // Incomplete first
      }
      return a.video.title.compareTo(b.video.title);
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      searchQuery = query;
      _applyFilters();
    });
  }

  void _onFilterChanged(String filter) {
    setState(() {
      selectedFilter = filter;
      _applyFilters();
    });
  }

  Future<void> _handleVideoTap(VideoWithContext videoContext) async {
    final video = videoContext.video;
    
    if (video.url?.isEmpty != false) {
      _showErrorSnack("Video URL not available");
      return;
    }

    try {
      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => VideoContentPage(
            videoUrl: video.url!,
            title: video.title,
            videoId: video.id,
            courseId: videoContext.courseId,
            trackId: videoContext.trackId,
          ),
        ),
      );

      if (result == true) {
        await video.markAsCompleted(
          syncToBackend: true,
          userId: _userId,
        );
        await video.refreshCompletionStatus(userId: _userId);
        
        if (mounted) {
          setState(() => _applyFilters());
          _showSuccessSnack("Video completed!");
        }
      }
    } catch (e) {
      _showErrorSnack("Error opening video: ${e.toString()}");
    }
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Search videos, courses, or tracks...',
          prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.grey[400]),
                  onPressed: () => _onSearchChanged(''),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
void _showUserMenu() {
    final signInController = Get.find<SignInController>();
    final user = signInController.user.value; // <- your logged-in user
    final name = user?.name ?? "Guest User";
    final email = user?.email ?? "guest@example.com";

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 40,
                backgroundColor: Colors.green,
                child: Icon(Icons.person, size: 50, color: Colors.white),
              ),
              const SizedBox(height: 12),
              Text(name,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(email, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text("Logout",
                    style: TextStyle(color: Colors.red)),
                onTap: () async {
                  Navigator.pop(context);

                  // Call logout logic from controller
                  await signInController.logout();

                  Get.snackbar(
                    "Logged Out",
                    "You have successfully logged out",
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );

                  // Navigate back to login screen
                  Get.offAllNamed(AppRoute.login);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterTabs() {
    return TabBar(
      controller: _tabController,
      
      labelColor: Colors.green,
      unselectedLabelColor: Colors.grey[600],
      labelStyle: const TextStyle(fontWeight: FontWeight.w600 ,fontSize: 14),
      onTap: (index) {
        final filters = ['All', 'Incomplete', 'Completed'];
        _onFilterChanged(filters[index]);
      },
      tabs: const [
        Tab(text: 'All'),
        Tab(text: 'Incomplete'),
        Tab(text: 'Completed'),
      ],
    );
  }

  Widget _buildStatsCards() {
    final totalVideos = allVideos.length;
    final completedVideos = allVideos.where((v) => v.video.isCompleted).length;
    final completionPercentage = totalVideos > 0 ? (completedVideos / totalVideos) * 100 : 0.0;

    return Container(
      margin: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(child: _buildStatCard('Total', totalVideos.toString(), Icons.video_library, Colors.blue)),
          const SizedBox(width: 12),
          Expanded(child: _buildStatCard('Completed', completedVideos.toString(), Icons.check_circle, Colors.green)),
          const SizedBox(width: 12),
          Expanded(child: _buildStatCard('Progress', '${completionPercentage.toInt()}%', Icons.trending_up, Colors.orange)),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoCard(VideoWithContext videoContext) {
    final video = videoContext.video;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _handleVideoTap(videoContext),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: video.isCompleted
                    ? [Colors.green[50]!, Colors.white]
                    : [Colors.blue[50]!, Colors.white],
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: video.isCompleted
                          ? [Colors.green[400]!, Colors.green[600]!]
                          : [Colors.blue[400]!, Colors.blue[600]!],
                    ),
                  ),
                  child: Icon(
                    video.isCompleted ? Icons.check_circle : Icons.play_arrow,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        video.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.book_outlined, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              videoContext.courseName,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.folder_outlined, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              videoContext.trackName,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            video.duration,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                          if (video.isCompleted) ...[
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green[600],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'COMPLETED',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: video.isCompleted ? Colors.green[600] : Colors.blue[600],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    String title;
    String subtitle;
    IconData icon;

    if (allVideos.isEmpty) {
      title = "No Videos Found";
      subtitle = "You don't have access to any videos yet";
      icon = Icons.video_library_outlined;
    } else if (filteredVideos.isEmpty) {
      title = "No Results";
      subtitle = "Try adjusting your search or filters";
      icon = Icons.search_off;
    } else {
      return const SizedBox.shrink();
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(60),
            ),
            child: Icon(
              icon,
              size: 60,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          if (allVideos.isNotEmpty) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                _onSearchChanged('');
                _onFilterChanged('All');
                _tabController.index = 0;
              },
              icon: const Icon(Icons.clear_all),
              label: const Text('Clear Filters'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[600],
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showErrorSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showSuccessSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
        appBar: AppBar(
            title: Text("All Videos" , style: TextStyle(color: Colors.green , fontWeight: FontWeight.bold),),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.menu, color: Colors.green),
              onPressed: () {
                _showUserMenu();
              },
            ),
          ),
      body: CustomScrollView(
        
        slivers: [
        
          if (isLoading)
            const SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.green),
                    SizedBox(height: 16),
                    Text("Loading your videos..."),
                  ],
                ),
              ),
            )
          else ...[
            SliverToBoxAdapter(child: _buildStatsCards()),
            SliverToBoxAdapter(child: _buildSearchBar()),
            SliverToBoxAdapter(child: _buildFilterTabs()),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            if (filteredVideos.isEmpty)
              SliverFillRemaining(child: _buildEmptyState())
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: Offset(0, 0.3),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: _fadeController,
                          curve: Interval(
                            index * 0.1,
                            1.0,
                            curve: Curves.easeOutCubic,
                          ),
                        )),
                        child: _buildVideoCard(filteredVideos[index]),
                      ),
                    );
                  },
                  childCount: filteredVideos.length,
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ],
      ),
      bottomNavigationBar: const CustomBottomBarPage(initialIndex: 1),
    );
  }
}