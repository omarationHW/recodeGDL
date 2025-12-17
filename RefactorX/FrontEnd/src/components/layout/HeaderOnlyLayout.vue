<template>
  <div class="header-only-layout">
    <AppHeader />
    <main class="main-content">
      <div class="content-wrapper">
        <router-view />
      </div>
    </main>
    <AppFooter />
  </div>
</template>

<script setup>
import AppHeader from './AppHeader.vue'
import AppFooter from './AppFooter.vue'
</script>

<style scoped>
.header-only-layout {
  display: flex;
  flex-direction: column;
  min-height: 100vh;
}

.main-content {
  flex: 1;
  width: 100%;
  padding: 0;
  margin-left: 0 !important;
  margin-top: 70px;
  margin-bottom: 50px;
  background-color: var(--slate-50, #f8fafc);
}

.content-wrapper {
  width: 100%;
  max-width: 100%;
  height: 100%;
}
</style>
