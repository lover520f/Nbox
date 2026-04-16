<template>
  <div class="home">
    <div class="header">
      <div class="user-info">
        <div class="avatar">👤</div>
        <div class="user-name">用户</div>
      </div>
      <div class="header-actions">
        <div class="search-icon">🔍</div>
        <div class="history-icon">🕒</div>
        <div class="favorite-icon">❤️</div>
      </div>
    </div>

    <div class="category-tabs">
      <div class="tab" :class="{ active: activeCategory === 'recommend' }" @click="activeCategory = 'recommend'">推荐</div>
      <div class="tab" :class="{ active: activeCategory === 'new' }" @click="activeCategory = 'new'">新剧</div>
      <div class="tab" :class="{ active: activeCategory === 'urban' }" @click="activeCategory = 'urban'">都市情感</div>
      <div class="tab more-tab">
        <span>更多</span>
        <span class="arrow">▼</span>
      </div>
    </div>

    <div class="content-grid">
      <div class="content-item" v-for="item in contentList" :key="item.id">
        <div class="content-image">
          <img :src="item.image" :alt="item.title" />
          <div class="content-info">
            <span class="episode">{{ item.episode }}</span>
            <span class="views">{{ item.views }}</span>
          </div>
        </div>
        <div class="content-title">{{ item.title }}</div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'Home',
  data() {
    return {
      activeCategory: 'recommend',
      contentList: [
        {
          id: 1,
          title: '义起风云枭雄路',
          image: 'https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=Chinese%20drama%20poster%20with%20action%20scene&image_size=square',
          episode: '逆袭 61集',
          views: '1085万'
        },
        {
          id: 2,
          title: '重回80：从小渔民到水产大王',
          image: 'https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=Chinese%20drama%20poster%20with%20fisherman%20theme&image_size=square',
          episode: '逆袭 61集',
          views: '1635万'
        },
        {
          id: 3,
          title: '出狱后，我举世无双',
          image: 'https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=Chinese%20drama%20poster%20with%20prison%20theme&image_size=square',
          episode: '逆袭 69集',
          views: '970万'
        },
        {
          id: 4,
          title: '流年深深深几许',
          image: 'https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=Chinese%20drama%20poster%20with%20romance%20theme&image_size=square',
          episode: '虐恋 70集',
          views: '199万'
        },
        {
          id: 5,
          title: '女神老婆赖上我',
          image: 'https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=Chinese%20drama%20poster%20with%20comedy%20theme&image_size=square',
          episode: '马甲 60集',
          views: '304万'
        },
        {
          id: 6,
          title: '万里江山入我怀',
          image: 'https://trae-api-cn.mchost.guru/api/ide/v1/text_to_image?prompt=Chinese%20drama%20poster%20with%20historical%20theme&image_size=square',
          episode: '穿越 74集',
          views: '274万'
        }
      ]
    }
  }
}
</script>

<style scoped>
.home {
  height: 100%;
}

.header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.user-info {
  display: flex;
  align-items: center;
}

.avatar {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  background-color: #333;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-right: 10px;
  font-size: 20px;
}

.user-name {
  font-size: 16px;
  font-weight: bold;
}

.header-actions {
  display: flex;
  gap: 15px;
}

.search-icon, .history-icon, .favorite-icon {
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

.content-item {
  cursor: pointer;
}

.content-image {
  position: relative;
  width: 100%;
  padding-bottom: 150%;
  overflow: hidden;
  border-radius: 8px;
  background-color: #333;
}

.content-image img {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.content-info {
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  background: linear-gradient(transparent, rgba(0,0,0,0.8));
  padding: 8px;
  font-size: 12px;
  color: #fff;
  display: flex;
  justify-content: space-between;
}

.content-title {
  margin-top: 8px;
  font-size: 14px;
  line-height: 1.3;
  height: 40px;
  overflow: hidden;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  -webkit-box-orient: vertical;
}

/* 响应式调整 */
@media (min-width: 768px) {
  .content-grid {
    grid-template-columns: repeat(auto-fill, minmax(180px, 1fr));
    gap: 20px;
  }
  
  .content-image {
    padding-bottom: 130%;
  }
  
  .content-title {
    font-size: 16px;
  }
}
</style>