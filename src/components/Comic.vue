<template>
  <div class="comic">
    <div class="header">
      <h2>漫画</h2>
      <div class="header-actions">
        <div class="search-icon">🔍</div>
        <div class="collection-icon">⭐</div>
      </div>
    </div>

    <div class="category-tabs">
      <div class="tab" :class="{ active: activeCategory === 'recommend' }" @click="activeCategory = 'recommend'">推荐</div>
      <div class="tab" :class="{ active: activeCategory === 'hot' }" @click="activeCategory = 'hot'">热门</div>
      <div class="tab" :class="{ active: activeCategory === 'new' }" @click="activeCategory = 'new'">更新</div>
      <div class="tab more-tab">
        <span>更多</span>
        <span class="arrow">▼</span>
      </div>
    </div>

    <div class="content-grid">
      <div class="comic-item" v-for="item in comicList" :key="item.id">
        <div class="comic-image">
          <img :src="item.image" :alt="item.title" />
          <div class="comic-badge" v-if="item.update">更新</div>
        </div>
        <div class="comic-title">{{ item.title }}</div>
        <div class="comic-status">{{ item.status }}</div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'Comic',
  data() {
    return {
      activeCategory: 'recommend',
      comicList: [
        {
          id: 1,
          title: '一人之下',
          image: 'https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=Chinese%20comic%20cover%20with%20martial%20arts%20theme&image_size=square',
          status: '连载中',
          update: true
        },
        {
          id: 2,
          title: '斗罗大陆',
          image: 'https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=Chinese%20comic%20cover%20with%20fantasy%20theme&image_size=square',
          status: '连载中',
          update: false
        },
        {
          id: 3,
          title: '斗破苍穹',
          image: 'https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=Chinese%20comic%20cover%20with%20action%20theme&image_size=square',
          status: '已完结',
          update: false
        },
        {
          id: 4,
          title: '完美世界',
          image: 'https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=Chinese%20comic%20cover%20with%20epic%20theme&image_size=square',
          status: '连载中',
          update: true
        }
      ]
    }
  }
}
</script>

<style scoped>
.comic {
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

.search-icon, .collection-icon {
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
  grid-template-columns: repeat(auto-fill, minmax(120px, 1fr));
  gap: 15px;
}

.comic-item {
  cursor: pointer;
}

.comic-image {
  position: relative;
  width: 100%;
  padding-bottom: 150%;
  overflow: hidden;
  border-radius: 8px;
  background-color: #333;
}

.comic-image img {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.comic-badge {
  position: absolute;
  top: 8px;
  right: 8px;
  background-color: #ff4757;
  color: #fff;
  padding: 4px 8px;
  border-radius: 4px;
  font-size: 12px;
  font-weight: bold;
}

.comic-title {
  margin-top: 8px;
  font-size: 14px;
  line-height: 1.3;
  height: 40px;
  overflow: hidden;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
}

.comic-status {
  font-size: 12px;
  color: #999;
  margin-top: 4px;
}

/* 响应式调整 */
@media (min-width: 768px) {
  .content-grid {
    grid-template-columns: repeat(auto-fill, minmax(180px, 1fr));
    gap: 20px;
  }
  
  .comic-image {
    padding-bottom: 130%;
  }
  
  .comic-title {
    font-size: 16px;
  }
}
</style>