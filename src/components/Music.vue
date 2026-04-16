<template>
  <div class="music">
    <div class="header">
      <h2>音乐</h2>
      <div class="header-actions">
        <div class="search-icon">🔍</div>
        <div class="playlist-icon">📋</div>
      </div>
    </div>

    <div class="category-tabs">
      <div class="tab" :class="{ active: activeCategory === 'recommend' }" @click="activeCategory = 'recommend'">推荐</div>
      <div class="tab" :class="{ active: activeCategory === 'hot' }" @click="activeCategory = 'hot'">热门</div>
      <div class="tab" :class="{ active: activeCategory === 'singer' }" @click="activeCategory = 'singer'">歌手</div>
      <div class="tab more-tab">
        <span>更多</span>
        <span class="arrow">▼</span>
      </div>
    </div>

    <div class="content-list">
      <div class="music-item" v-for="item in musicList" :key="item.id">
        <div class="music-info">
          <div class="music-title">{{ item.title }}</div>
          <div class="music-artist">{{ item.artist }}</div>
        </div>
        <div class="music-actions">
          <div class="play-icon">▶️</div>
          <div class="more-icon">⋮</div>
        </div>
      </div>
    </div>

    <!-- 底部播放栏 -->
    <div class="player-bar">
      <div class="player-info">
        <div class="player-title">当前播放</div>
        <div class="player-artist">艺术家</div>
      </div>
      <div class="player-controls">
        <div class="control-icon">⏮️</div>
        <div class="control-icon play">▶️</div>
        <div class="control-icon">⏭️</div>
      </div>
      <div class="player-progress">
        <div class="progress-bar">
          <div class="progress-fill" style="width: 30%"></div>
        </div>
        <div class="progress-time">0:30 / 3:45</div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'Music',
  data() {
    return {
      activeCategory: 'recommend',
      musicList: [
        {
          id: 1,
          title: '起风了',
          artist: '买辣椒也用券'
        },
        {
          id: 2,
          title: '孤勇者',
          artist: '陈奕迅'
        },
        {
          id: 3,
          title: '海阔天空',
          artist: 'Beyond'
        },
        {
          id: 4,
          title: '七里香',
          artist: '周杰伦'
        },
        {
          id: 5,
          title: '青藏高原',
          artist: '韩红'
        }
      ]
    }
  }
}
</script>

<style scoped>
.music {
  height: 100%;
  position: relative;
}

.header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.header h2 {
  font-size: 24px;
  font-weight: bold;
}

.header-actions {
  display: flex;
  gap: 15px;
}

.search-icon, .playlist-icon {
  font-size: 20px;
  cursor: pointer;
}

.category-tabs {
  display: flex;
  gap: 15px;
  margin-bottom: 20px;
  overflow-x: auto;
  padding-bottom: 10px;
}

.tab {
  padding: 8px 16px;
  background-color: #333;
  border-radius: 20px;
  font-size: 14px;
  cursor: pointer;
  white-space: nowrap;
}

.tab.active {
  background-color: #4CAF50;
  color: #fff;
}

.more-tab {
  display: flex;
  align-items: center;
  gap: 5px;
}

.arrow {
  font-size: 12px;
}

.content-list {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.music-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 15px;
  background-color: #1e1e1e;
  border-radius: 8px;
  cursor: pointer;
}

.music-info {
  flex: 1;
}

.music-title {
  font-size: 16px;
  font-weight: bold;
}

.music-artist {
  font-size: 14px;
  color: #999;
  margin-top: 4px;
}

.music-actions {
  display: flex;
  gap: 15px;
}

.play-icon, .more-icon {
  font-size: 20px;
  cursor: pointer;
}

/* 底部播放栏 */
.player-bar {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  background-color: #1e1e1e;
  border-top: 1px solid #333;
  padding: 10px 20px;
  display: flex;
  align-items: center;
  gap: 20px;
}

.player-info {
  flex: 1;
}

.player-title {
  font-size: 14px;
  font-weight: bold;
}

.player-artist {
  font-size: 12px;
  color: #999;
  margin-top: 2px;
}

.player-controls {
  display: flex;
  gap: 20px;
  align-items: center;
}

.control-icon {
  font-size: 20px;
  cursor: pointer;
}

.control-icon.play {
  font-size: 24px;
}

.player-progress {
  flex: 2;
  display: flex;
  align-items: center;
  gap: 10px;
}

.progress-bar {
  flex: 1;
  height: 4px;
  background-color: #333;
  border-radius: 2px;
  overflow: hidden;
}

.progress-fill {
  height: 100%;
  background-color: #4CAF50;
  border-radius: 2px;
}

.progress-time {
  font-size: 12px;
  color: #999;
  min-width: 80px;
}

/* 响应式调整 */
@media (max-width: 767px) {
  .player-bar {
    bottom: 60px;
  }
  
  .content-list {
    padding-bottom: 100px;
  }
}
</style>