<template>
  <div class="recuperacion-container">
    <h1 class="page-title">Recuperación</h1>
    <p class="page-subtitle">Sistema de recuperación de datos del módulo de apremios</p>
    
    <div class="recovery-options">
      <div class="option-card">
        <h3>Recuperar Datos</h3>
        <p>Recuperar información de adeudos</p>
        <button class="btn btn-primary">Iniciar Recuperación</button>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'Recuperacion'
}
</script>

<style scoped>
.recuperacion-container {
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

.recovery-options {
  max-width: 600px;
  margin: 0 auto;
}

.option-card {
  background: white;
  padding: 25px;
  border-radius: 10px;
  box-shadow: 0 2px 10px rgba(0,0,0,0.1);
  text-align: center;
}

.btn {
  padding: 10px 20px;
  border: none;
  border-radius: 5px;
  cursor: pointer;
  font-size: 14px;
  font-weight: bold;
}

.btn-primary {
  background-color: #3498db;
  color: white;
}
</style>