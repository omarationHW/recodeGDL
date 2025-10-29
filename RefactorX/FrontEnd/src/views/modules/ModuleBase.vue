<template>
  <div class="module-view">
    <h1><font-awesome-icon :icon="icon" /> {{ title }}</h1>
    <div class="module-content municipal-card">
      <slot></slot>
    </div>
  </div>
</template>

<script setup>
defineProps({
  title: String,
  icon: String
})
</script>

<style scoped>
.module-view {
  width: 100%;
  padding: 0;
}

.module-view h1 {
  margin-bottom: 1.5rem;
  color: var(--municipal-primary);
  font-weight: var(--font-weight-bold);
  font-family: var(--font-heading);
  display: flex;
  align-items: center;
  gap: 1rem;
  font-size: 1.875rem;
}

.module-content {
  padding: 2rem;
  width: 100%;
}
</style>
