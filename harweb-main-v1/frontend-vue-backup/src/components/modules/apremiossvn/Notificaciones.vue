<template>
  <div class="notificaciones-container">
    <h1 class="page-title">Notificaciones</h1>
    <p class="page-subtitle">Sistema de notificaciones para el módulo de apremios</p>
    
    <div class="notifications-list">
      <div class="notification-item">
        <h3>Sistema funcionando correctamente</h3>
        <p>El sistema de notificaciones está activo</p>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'Notificaciones'
}
</script>

<style scoped>
.notificaciones-container {
  padding: 20px;
  background-color: #f8f9fa;
  min-height: 100vh;
}

.page-title {
  color: #2c3e50;
  font-size: 2.5rem;
  margin-bottom: 10px;
  text-align: center;
}

.page-subtitle {
  color: #7f8c8d;
  font-size: 1.1rem;
  text-align: center;
  margin-bottom: 30px;
}

.notifications-list {
  max-width: 800px;
  margin: 0 auto;
}

.notification-item {
  background: white;
  padding: 20px;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
  margin-bottom: 15px;
}
</style>