<template>
  <div class="module-page">
    <div class="page-header">
      <h1 class="page-title">
        <i class="fas fa-search me-2"></i>
        Búsqueda
      </h1>
      <p class="page-subtitle">Trámite Trunk - Búsqueda de registros</p>
    </div>
    
    <div class="content-card">
      <div class="card-body">
        <p>Página en desarrollo - Búsqueda</p>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'Busque'
}
</script>

<style scoped>
.module-page {
  padding: 2rem;
  max-width: 1200px;
  margin: 0 auto;
}

.page-header {
  margin-bottom: 2rem;
  text-align: center;
}

.page-title {
  font-size: 2rem;
  font-weight: 600;
  color: var(--municipal-blue);
  margin-bottom: 0.5rem;
}

.page-subtitle {
  color: var(--slate-600);
  font-size: 1rem;
}

.content-card {
  background: white;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
  padding: 2rem;
}
</style>