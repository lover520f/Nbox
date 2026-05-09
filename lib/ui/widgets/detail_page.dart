import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../core/models/video_source.dart';
import '../../core/services/spider_service.dart';
import '../../core/services/player_service.dart';
import 'player_page.dart';

class DetailPage extends StatefulWidget {
  final Video video;

  const DetailPage({super.key, required this.video});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  Video? _video;
  bool _isLoading = true;
  String? _error;
  int _selectedSourceIndex = 0;
  int _selectedEpisodeIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final spiderService = context.read<SpiderService>();
      final result = await spiderService.detailContent([widget.video.vodId ?? '']);
      
      setState(() {
        _video = result['list'] != null && (result['list'] as List).isNotEmpty
            ? Video.fromJson((result['list'] as List).first as Map<String, dynamic>)
            : widget.video;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
        _video = widget.video;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                _buildAppBar(),
                SliverToBoxAdapter(
                  child: _buildContent(),
                ),
              ],
            ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: _video?.vodPic ?? '',
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => Container(
                color: Colors.grey[900],
                child: const Icon(Icons.movie, size: 64, color: Colors.white54),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Theme.of(context).scaffoldBackgroundColor,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final video = _video ?? widget.video;
    final sources = video.playSources;
    final episodes = video.episodes;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            video.vodName ?? '未知',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _buildTags(),
          const SizedBox(height: 16),
          if (video.vodDirector != null && video.vodDirector!.isNotEmpty)
            _buildInfoRow('导演', video.vodDirector!),
          if (video.vodActor != null && video.vodActor!.isNotEmpty)
            _buildInfoRow('主演', video.vodActor!),
          if (video.vodContent != null && video.vodContent!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              '简介',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              video.vodContent!,
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 24),
          if (sources.isNotEmpty) ...[
            Text(
              '播放源',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildSourceTabs(sources),
            const SizedBox(height: 16),
            if (episodes.isNotEmpty && _selectedSourceIndex < episodes.length)
              _buildEpisodeGrid(episodes[_selectedSourceIndex]),
          ],
        ],
      ),
    );
  }

  Widget _buildTags() {
    final tags = <String>[];
    if (_video?.vodYear != null) tags.add(_video!.vodYear!);
    if (_video?.vodArea != null) tags.add(_video!.vodArea!);
    if (_video?.vodLang != null) tags.add(_video!.vodLang!);

    return Wrap(
      spacing: 8,
      children: tags.map((tag) {
        return Chip(
          label: Text(tag, style: const TextStyle(fontSize: 12)),
          padding: EdgeInsets.zero,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        );
      }).toList(),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white54,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceTabs(List<String> sources) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(sources.length, (index) {
          final isSelected = index == _selectedSourceIndex;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(sources[index]),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedSourceIndex = index;
                  });
                }
              },
            ),
          );
        }),
      ),
    );
  }

  Widget _buildEpisodeGrid(Episode episode) {
    final urls = episode.url?.split('#') ?? [];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(urls.length, (index) {
        final parts = urls[index].split('\$');
        final name = parts.isNotEmpty ? parts[0] : '${index + 1}';
        final url = parts.length > 1 ? parts[1] : '';
        final isSelected = index == _selectedEpisodeIndex;

        return InkWell(
          onTap: () => _playEpisode(episode.source ?? '', url),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 80,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: isSelected 
                  ? Theme.of(context).primaryColor 
                  : Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                name,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        );
      }),
    );
  }

  void _playEpisode(String source, String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlayerPage(
          title: _video?.vodName ?? '未知',
          sourceName: source,
          url: url,
        ),
      ),
    );
  }
}
