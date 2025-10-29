<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon">
        <font-awesome-icon icon="gavel" />
      </div>
      <div class="module-view-info">
        <h1>Test Simple - Apremios</h1>
        <p>Prueba de visualización</p>
      </div>
    </div>

    <div class="module-view-content">
      <div class="municipal-card">
        <div class="municipal-card-header">
          <h5>Formulario de Prueba</h5>
        </div>
        <div class="municipal-card-body">
          <div class="form-row">
            <div class="form-group">
              <label class="municipal-form-label">Campo 1</label>
              <input type="text" class="municipal-form-control" value="Test 1">
            </div>
            <div class="form-group">
              <label class="municipal-form-label">Campo 2</label>
              <input type="text" class="municipal-form-control" value="Test 2">
            </div>
          </div>
          <button class="btn-municipal-primary">Guardar</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
console.log('TestSimple component loaded')
</script>
