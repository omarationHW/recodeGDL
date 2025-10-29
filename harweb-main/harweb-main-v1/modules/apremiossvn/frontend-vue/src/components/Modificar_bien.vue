<template>
  <div class="modificar-bien-container">
    <h1 class="page-title">Modificar Bien</h1>
    <p class="page-subtitle">Modificación de datos de bienes en proceso de cobranza coactiva</p>
    
    <div class="form-card">
      <form>
        <div class="form-row">
          <div class="form-group">
            <label>Folio:</label>
            <input type="text" class="form-control" placeholder="Ingrese folio">
          </div>
          <div class="form-group">
            <label>Bien:</label>
            <input type="text" class="form-control" placeholder="Descripción del bien">
          </div>
        </div>
        <div class="form-actions">
          <button type="button" class="btn btn-primary">Buscar</button>
          <button type="button" class="btn btn-success">Guardar</button>
        </div>
      </form>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ModificarBien'
}
</script>

<style scoped>
.modificar-bien-container {
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

.form-card {
  background: white;
  padding: 25px;
  border-radius: 10px;
  box-shadow: 0 2px 10px rgba(0,0,0,0.1);
  max-width: 600px;
  margin: 0 auto;
}

.form-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 20px;
  margin-bottom: 20px;
}

.form-group {
  display: flex;
  flex-direction: column;
}

.form-group label {
  margin-bottom: 5px;
  font-weight: bold;
  color: #2c3e50;
}

.form-control {
  padding: 10px;
  border: 1px solid #bdc3c7;
  border-radius: 5px;
  font-size: 14px;
}

.form-actions {
  display: flex;
  gap: 10px;
  justify-content: center;
}

.btn {
  padding: 10px 20px;
  border: none;
  border-radius: 5px;
  cursor: pointer;
  font-size: 14px;
  font-weight: bold;
}

.btn-primary { background-color: #3498db; color: white; }
.btn-success { background-color: #27ae60; color: white; }
</style>