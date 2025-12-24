<template>
  <li class="nav-item">
    <!-- Si el item tiene hijos, es un nodo expandible -->
    <div v-if="item.children && item.children.length > 0" class="nav-parent">
      <div
        class="nav-link nav-parent-link"
        @click="toggleExpanded"
        :class="{ 'expanded': isExpanded, 'highlight': hasSearchMatch }"
      >
        <font-awesome-icon :icon="item.icon || 'folder'" class="nav-icon" />
        <span class="nav-text" v-html="highlightedLabel"></span>
        <font-awesome-icon
          :icon="isExpanded ? 'chevron-down' : 'chevron-right'"
          class="nav-chevron"
        />
      </div>

      <!-- Submenu recursivo -->
      <transition name="submenu">
        <ul v-show="isExpanded" class="nav-submenu">
          <MenuItem
            v-for="child in item.children"
            :key="child.path || child.label"
            :item="child"
            :level="level + 1"
            :search-query="searchQuery"
          />
        </ul>
      </transition>
    </div>

    <!-- Si no tiene hijos, es un enlace normal -->
    <router-link
      v-else
      :to="item.path"
      class="nav-link"
      :class="{ 'active': isActive, 'highlight': hasSearchMatch }"
    >
      <font-awesome-icon :icon="item.icon || 'file'" class="nav-icon" />
      <span class="nav-text" v-html="highlightedLabel"></span>
    </router-link>
  </li>
</template>

<script setup>
import { ref, computed } from 'vue'
import { useRoute } from 'vue-router'

const props = defineProps({
  item: {
    type: Object,
    required: true
  },
  level: {
    type: Number,
    default: 0
  },
  searchQuery: {
    type: String,
    default: ''
  }
})

const route = useRoute()
const isExpanded = ref(false)

const isActive = computed(() => {
  return route.path === props.item.path
})

// Verificar si hay coincidencia con la búsqueda
const hasSearchMatch = computed(() => {
  if (!props.searchQuery) return false
  return props.item.label.toLowerCase().includes(props.searchQuery.toLowerCase())
})

// Resaltar el término de búsqueda en el label
const highlightedLabel = computed(() => {
  if (!props.searchQuery || !hasSearchMatch.value) {
    return props.item.label
  }

  const regex = new RegExp(`(${props.searchQuery})`, 'gi')
  return props.item.label.replace(regex, '<mark class="search-highlight">$1</mark>')
})

const toggleExpanded = () => {
  isExpanded.value = !isExpanded.value
}
</script>

<style scoped>
.nav-link.highlight {
  background-color: rgba(234, 130, 21, 0.08);
  border-left: 3px solid var(--municipal-primary);
}

:deep(.search-highlight) {
  background-color: var(--gov-yellow);
  color: var(--slate-900);
  font-weight: var(--font-weight-bold);
  padding: 0.1rem 0.2rem;
  border-radius: 2px;
}
</style>
