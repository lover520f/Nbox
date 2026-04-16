<template>
  <div class="live">
    <div class="header">
      <h2>直播</h2>
      <div class="header-actions">
        <div class="search-icon">🔍</div>
        <div class="category-icon">📺</div>
      </div>
    </div>

    <div class="category-tabs">
      <div class="tab" :class="{ active: activeCategory === 'recommend' }" @click="activeCategory = 'recommend'">推荐</div>
      <div class="tab" :class="{ active: activeCategory === 'game' }" @click="activeCategory = 'game'">游戏</div>
      <div class="tab" :class="{ active: activeCategory === 'entertainment' }" @click="activeCategory = 'entertainment'">娱乐</div>
      <div class="tab more-tab">
        <span>更多</span>
        <span class="arrow">▼</span>
      </div>
    </div>

    <div class="content-grid">
      <div class="live-item" v-for="item in liveList" :key="item.id">
        <div class="live-image">
          <img :src="item.image" :alt="item.title" />
          <div class="live-badge">直播中</div>
          <div class="viewer-count">{{ item.viewers }}</div>
        </div>
        <div class="live-info">
          <div class="live-title">{{ item.title }}</div>
          <div class="live-streamer">{{ item.streamer }}</div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'Live',
  data() {
    return {
      activeCategory: 'recommend',
      liveList: [
        {
          id: 1,
          title: '王者荣耀：巅峰赛冲分',
          streamer: '张三',
          image: 'https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=Mobile%20game%20live%20streaming%20scene&image_size=square',
          viewers: '12.3万'
        },
        {
          id: 2,
          title: '英雄联盟：排位赛',
          streamer: '李四',
          image: 'https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=PC%20game%20live%20streaming%20scene&image_size=square',
          viewers: '8.7万'
        },
        {
          id: 3,
          title: '音乐演唱会',
          streamer: '王五',
          image: 'https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=Music%20concert%20live%20streaming%20scene&image_size=square',
          viewers: '5.2万'
        },
        {
          id: 4,
          title: '美食制作',
          streamer: '赵六',
          image: 'https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=Cooking%20live%20streaming%20scene&image_size=square',
          viewers: '3.8万'
        }
      ]
    }
  }
}
</script>

<style scoped>
.live {
  height: 100%;
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

.search-icon, .category-icon {
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

.content-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(160px, 1fr));
  gap: 15px;
}

.live-item {
  cursor: pointer;
}

.live-image {
  position: relative;
  width: 100%;
  padding-bottom: 90%;
  overflow: hidden;
  border-radius: 8px;
  background-color: #333;
}

.live-image img {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.live-badge {
  position: absolute;
  top: 8px;
  left: 8px;
  background-color: #ff4757;
  color: #fff;
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 12px;
  font-weight: bold;
}

.viewer-count {
  position: absolute;
  bottom: 8px;
  right: 8px;
  background-color: rgba(0, 0, 0, 0.7);
  color: #fff;
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 12px;
}

.live-info {
  margin-top: 8px;
}

.live-title {
  font-size: 14px;
  line-height: 1.3;
  height: 40px;
  overflow: hidden;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
}

.live-streamer {
  font-size: 12px;
  color: #999;
  margin-top: 4px;
}

/* 响应式调整 */
@media (min-width: 768px) {
  .content-grid {
    grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
    gap: 20px;
  }
  
  .live-title {
    font-size: 16px;
  }
}
</style>