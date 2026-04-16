<template>
  <div class="app">
    <div class="main-content">
      <!-- 移动端导航栏 -->
      <div class="mobile-nav" v-if="isMobile">
        <div class="nav-item" :class="{ active: currentTab === 'home' }" @click="currentTab = 'home'">
          <span class="nav-icon home-icon"></span>
          <span class="nav-text">首页</span>
        </div>
        <div class="nav-item" :class="{ active: currentTab === 'novel' }" @click="currentTab = 'novel'">
          <span class="nav-icon novel-icon"></span>
          <span class="nav-text">小说</span>
        </div>
        <div class="nav-item" :class="{ active: currentTab === 'comic' }" @click="currentTab = 'comic'">
          <span class="nav-icon comic-icon"></span>
          <span class="nav-text">漫画</span>
        </div>
        <div class="nav-item" :class="{ active: currentTab === 'music' }" @click="currentTab = 'music'">
          <span class="nav-icon music-icon"></span>
          <span class="nav-text">音乐</span>
        </div>
        <div class="nav-item" :class="{ active: currentTab === 'live' }" @click="currentTab = 'live'">
          <span class="nav-icon live-icon"></span>
          <span class="nav-text">直播</span>
        </div>
        <div class="nav-item" :class="{ active: currentTab === 'settings' }" @click="currentTab = 'settings'">
          <span class="nav-icon settings-icon"></span>
          <span class="nav-text">设置</span>
        </div>
      </div>

      <!-- PC端侧边栏 -->
      <div class="pc-sidebar" v-else>
        <div class="sidebar-item" :class="{ active: currentTab === 'home' }" @click="currentTab = 'home'">
          <span class="sidebar-icon home-icon"></span>
          <span class="sidebar-text">首页</span>
        </div>
        <div class="sidebar-item" :class="{ active: currentTab === 'novel' }" @click="currentTab = 'novel'">
          <span class="sidebar-icon novel-icon"></span>
          <span class="sidebar-text">小说</span>
        </div>
        <div class="sidebar-item" :class="{ active: currentTab === 'comic' }" @click="currentTab = 'comic'">
          <span class="sidebar-icon comic-icon"></span>
          <span class="sidebar-text">漫画</span>
        </div>
        <div class="sidebar-item" :class="{ active: currentTab === 'music' }" @click="currentTab = 'music'">
          <span class="sidebar-icon music-icon"></span>
          <span class="sidebar-text">音乐</span>
        </div>
        <div class="sidebar-item" :class="{ active: currentTab === 'live' }" @click="currentTab = 'live'">
          <span class="sidebar-icon live-icon"></span>
          <span class="sidebar-text">直播</span>
        </div>
        <div class="sidebar-item" :class="{ active: currentTab === 'settings' }" @click="currentTab = 'settings'">
          <span class="sidebar-icon settings-icon"></span>
          <span class="sidebar-text">设置</span>
        </div>
      </div>

      <!-- 内容区域 -->
      <div class="content">
        <component :is="currentComponent" />
      </div>
    </div>
  </div>
</template>

<script>
import Home from './components/Home.vue'
import Novel from './components/Novel.vue'
import Comic from './components/Comic.vue'
import Music from './components/Music.vue'
import Live from './components/Live.vue'
import Settings from './components/Settings.vue'

export default {
  name: 'App',
  components: {
    Home,
    Novel,
    Comic,
    Music,
    Live,
    Settings
  },
  data() {
    return {
      currentTab: 'home',
      isMobile: window.innerWidth < 768
    }
  },
  computed: {
    currentComponent() {
      return this.currentTab.charAt(0).toUpperCase() + this.currentTab.slice(1)
    }
  },
  mounted() {
    window.addEventListener('resize', this.handleResize)
  },
  beforeUnmount() {
    window.removeEventListener('resize', this.handleResize)
  },
  methods: {
    handleResize() {
      this.isMobile = window.innerWidth < 768
    }
  }
}
</script>

<style>
.app {
  width: 100vw;
  height: 100vh;
  background-color: #121212;
  color: #fff;
  font-family: Arial, sans-serif;
}

.main-content {
  display: flex;
  height: 100%;
  flex-direction: column;
}

/* 移动端导航 */
.mobile-nav {
  display: flex;
  justify-content: space-around;
  align-items: center;
  height: 60px;
  background-color: #1e1e1e;
  border-top: 1px solid #333;
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  z-index: 100;
}

.nav-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  width: 20%;
  height: 100%;
  cursor: pointer;
}

.nav-item.active {
  color: #4CAF50;
}

.nav-icon {
  width: 24px;
  height: 24px;
  margin-bottom: 4px;
}

.nav-text {
  font-size: 12px;
}

/* PC端侧边栏 */
.pc-sidebar {
  width: 80px;
  background-color: #1e1e1e;
  border-right: 1px solid #333;
  display: flex;
  flex-direction: column;
  align-items: center;
  padding-top: 20px;
}

.sidebar-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  width: 100%;
  height: 80px;
  cursor: pointer;
  transition: all 0.3s ease;
}

.sidebar-item:hover {
  background-color: #333;
}

.sidebar-item.active {
  color: #4CAF50;
  background-color: #333;
}

.sidebar-icon {
  width: 28px;
  height: 28px;
  margin-bottom: 8px;
}

.sidebar-text {
  font-size: 12px;
}

/* 内容区域 */
.content {
  flex: 1;
  padding: 20px;
  overflow-y: auto;
}

/* 图标样式 */
.home-icon::before {
  content: "🏠";
  font-size: 24px;
}

.novel-icon::before {
  content: "📚";
  font-size: 24px;
}

.comic-icon::before {
  content: "📖";
  font-size: 24px;
}

.music-icon::before {
  content: "🎵";
  font-size: 24px;
}

.live-icon::before {
  content: "📺";
  font-size: 24px;
}

.settings-icon::before {
  content: "⚙️";
  font-size: 24px;
}

/* 响应式布局 */
@media (min-width: 768px) {
  .main-content {
    flex-direction: row;
  }
  
  .content {
    flex: 1;
  }
  
  .mobile-nav {
    display: none;
  }
}

@media (max-width: 767px) {
  .pc-sidebar {
    display: none;
  }
  
  .content {
    padding-bottom: 80px;
  }
}
</style>