<template>
  <div class="dashboard">
    <h1>Dashboard</h1>
    <div class="dashboard-grid">
      <div class="card" v-for="module in modules" :key="module.name">
        <div class="card-icon">
          <font-awesome-icon :icon="module.icon" />
        </div>
        <div class="card-content">
          <h3>{{ module.label }}</h3>
          <router-link :to="module.path" class="card-link">
            Ir al módulo →
          </router-link>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
const modules = [
  { name: 'aseo-contratado', label: 'Aseo Contratado', icon: 'broom', path: '/aseo-contratado' },
  { name: 'cementerio', label: 'Cementerio', icon: 'cross', path: '/cementerio' },
  { name: 'estacionamiento-exclusivo', label: 'Estacionamiento Exclusivo', icon: 'square-parking', path: '/estacionamiento-exclusivo' },
  { name: 'estacionamiento-publico', label: 'Estacionamiento Público', icon: 'car', path: '/estacionamiento-publico' },
  { name: 'mercados', label: 'Mercados', icon: 'store', path: '/mercados' },
  { name: 'multas-reglamentos', label: 'Multas y Reglamentos', icon: 'file-contract', path: '/multas-reglamentos' },
  { name: 'otras-obligaciones', label: 'Otras Obligaciones', icon: 'file-lines', path: '/otras-obligaciones' },
  { name: 'padron-licencias', label: 'Padrón de Licencias', icon: 'id-card', path: '/padron-licencias' }
]
</script>
