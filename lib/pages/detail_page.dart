import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/video.dart';
import '../providers/app_provider.dart';
import '../utils/spider_engine.dart';
import 'player_page.dart';

class DetailPage extends StatefulWidget {
  final Video video;

  const DetailPage({super.key, required this.video});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  Video? _videoDetail;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() => _isLoading = true);
    final provider = Provider.of<AppProvider>(context, listen: false);
    if (provider.vodSources.isNotEmpty) {
      _videoDetail = await SpiderEngine.getVideoDetail(
        provider.vodSources.first.url,
        widget.video.id,
      );
    }
    setState(() => _isLoading = false);
  }

  void _playVideo(Video video, String episodeUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlayerPage(
          video: video,
          playUrl: episodeUrl,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Video currentVideo = _videoDetail ?? widget.video;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('详情', style: TextStyle(color: Colors.white)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.blue))
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(currentVideo),
                  _buildInfo(currentVideo),
                  _buildEpisodes(currentVideo),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader(Video video) {
    return Stack(
      children: [
        video.cover.isNotEmpty
            ? Image.network(
                video.cover,
                height: 250,
                width: double.infinity,
                fit: BoxFit.cover,
              )
            : Container(height: 250, color: Colors.grey),
        Container(
          height: 250,
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Color(0xFF1A1A1A)],
            ),
          ),
        ),
        Positioned(
          bottom: 20,
          left: 20,
          right: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                video.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  if (video.year != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(video.year!, style: const TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                  const SizedBox(width: 8),
                  if (video.type != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(video.type!, style: const TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfo(Video video) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (video.actor != null)
            _buildInfoRow('主演:', video.actor!),
          if (video.director != null)
            _buildInfoRow('导演:', video.director!),
          if (video.region != null)
            _buildInfoRow('地区:', video.region!),
          if (video.desc != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('简介:', style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 4),
                  Text(
                    video.desc!,
                    style: const TextStyle(color: Colors.white54, fontSize: 14),
                    textAlign: TextAlign.justify,
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => _playVideo(video, video.playUrl ?? video.url),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                '立即播放',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white54, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEpisodes(Video video) {
    if (video.episodes == null || video.episodes!.isEmpty) {
      return const SizedBox();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '剧集列表',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              childAspectRatio: 2.5,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: video.episodes!.length,
            itemBuilder: (context, index) {
              var episode = video.episodes![index];
              return ElevatedButton(
                onPressed: () => _playVideo(video, episode.url),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D2D2D),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: Text(episode.name),
              );
            },
          ),
        ],
      ),
    );
  }
}
