<template>
  <div class="novel">
    <div class="header">
      <h2>小说</h2>
      <div class="header-actions">
        <div class="search-icon">🔍</div>
        <div class="bookshelf-icon">📚</div>
      </div>
    </div>

    <div class="category-tabs">
      <div class="tab" :class="{ active: activeCategory === 'recommend' }" @click="activeCategory = 'recommend'">推荐</div>
      <div class="tab" :class="{ active: activeCategory === 'hot' }" @click="activeCategory = 'hot'">热门</div>
      <div class="tab" :class="{ active: activeCategory === 'new' }" @click="activeCategory = 'new'">新书</div>
      <div class="tab more-tab">
        <span>更多</span>
        <span class="arrow">▼</span>
      </div>
    </div>

    <div class="content-list">
      <div class="novel-item" v-for="item in novelList" :key="item.id">
        <div class="novel-image">
          <img :src="item.image" :alt="item.title" />
        </div>
        <div class="novel-info">
          <div class="novel-title">{{ item.title }}</div>
          <div class="novel-author">{{ item.author }}</div>
          <div class="novel-description">{{ item.description }}</div>
          <div class="novel-tags">
            <span class="tag" v-for="tag in item.tags" :key="tag">{{ tag }}</span>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'Novel',
  data() {
    return {
      activeCategory: 'recommend',
      novelList: [
        {
          id: 1,
          title: '斗破苍穹',
          author: '天蚕土豆',
          image: 'https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=Chinese%20novel%20cover%20with%20martial%20arts%20theme&image_size=portrait_4_3',
          description: '这里是天才云集的世界，这里是斗气的天下！',
          tags: ['玄幻', '热血', '冒险']
        },
        {
          id: 2,
          title: '庆余年',
          author: '猫腻',
          image: 'https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=Chinese%20novel%20cover%20with%20historical%20theme&image_size=portrait_4_3',
          description: '一个普通青年穿越到古代的故事',
          tags: ['穿越', '历史', '权谋']
        },
        {
          id: 3,
          title: '三体',
          author: '刘慈欣',
          image: 'https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=Chinese%20novel%20cover%20with%20science%20fiction%20theme&image_size=portrait_4_3',
          description: '地球文明与三体文明的碰撞',
          tags: ['科幻', '硬科幻', '宇宙']
        }
      ]
    }
  }
}
</script>

<style scoped>
.novel {
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

.search-icon, .bookshelf-icon {
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
  gap: 15px;
}

.novel-item {
  display: flex;
  gap: 15px;
  padding: 15px;
  background-color: #1e1e1e;
  border-radius: 8px;
  cursor: pointer;
}

.novel-image {
  width: 80px;
  height: 120px;
  border-radius: 4px;
  overflow: hidden;
  background-color: #333;
}

.novel-image img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.novel-info {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.novel-title {
  font-size: 16px;
  font-weight: bold;
}

.novel-author {
  font-size: 14px;
  color: #999;
}

.novel-description {
  font-size: 14px;
  line-height: 1.4;
  color: #ccc;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

.novel-tags {
  display: flex;
  gap: 8px;
  margin-top: auto;
}

.tag {
  padding: 4px 8px;
  background-color: #333;
  border-radius: 12px;
  font-size: 12px;
  color: #999;
}
</style>