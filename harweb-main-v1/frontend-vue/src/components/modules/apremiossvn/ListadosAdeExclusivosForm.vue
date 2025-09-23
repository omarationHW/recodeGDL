<template>
  <div class="exclusivos-form">
    <h3>Listado de Adeudos - Estacionamientos Exclusivos</h3>
    
    <div class="form-row">
      <div class="form-group">
        <label>Fecha Desde:</label>
        <input v-model="localForm.fechaDesde" type="date" class="form-control" />
      </div>
      <div class="form-group">
        <label>Fecha Hasta:</label>
        <input v-model="localForm.fechaHasta" type="date" class="form-control" />
      </div>
    </div>

    <div class="form-row">
      <div class="form-group">
        <label>Colonia:</label>
        <select v-model="localForm.colonia" class="form-control">
          <option value="">Todas las colonias</option>
          <option value="centro">Centro</option>
          <option value="americana">Americana</option>
          <option value="providencia">Providencia</option>
          <option value="chapalita">Chapalita</option>
        </select>
      </div>
      <div class="form-group">
        <label>Calle:</label>
        <input v-model="localForm.calle" type="text" class="form-control" placeholder="Nombre de la calle" />
      </div>
    </div>

    <div class="form-row">
      <div class="form-group">
        <label>Número:</label>
        <input v-model="localForm.numero" type="text" class="form-control" placeholder="Número del domicilio" />
      </div>
      <div class="form-group">
        <label>Estado del Permiso:</label>
        <select v-model="localForm.estadoPermiso" class="form-control">
          <option value="">Todos</option>
          <option value="activo">Activo</option>
          <option value="vencido">Vencido</option>
          <option value="suspendido">Suspendido</option>
          <option value="cancelado">Cancelado</option>
        </select>
      </div>
    </div>

    <div class="form-actions">
      <button @click="buscar" type="button" class="btn btn-primary">Buscar</button>
      <button @click="limpiar" type="button" class="btn btn-secondary">Limpiar</button>
      <button @click="exportar" type="button" class="btn btn-success">Exportar Excel</button>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ListadosAdeExclusivosForm',
  props: {
    form: {
      type: Object,
      default: () => ({})
    }
  },
  data() {
    return {
      localForm: {
        fechaDesde: '',
        fechaHasta: '',
        colonia: '',
        calle: '',
        numero: '',
        estadoPermiso: ''
      }
    }
  },
  methods: {
    buscar() {
      this.$emit('submit', {
        ...this.form,
        ...this.localForm,
        tipo: 'exclusivos'
      });
    },
    limpiar() {
      this.localForm = {
        fechaDesde: '',
        fechaHasta: '',
        colonia: '',
        calle: '',
        numero: '',
        estadoPermiso: ''
      };
    },
    exportar() {
      this.$emit('export', {
        ...this.form,
        ...this.localForm,
        tipo: 'exclusivos'
      });
    }
  }
}
</script>

<style scoped>
.exclusivos-form {
  background: white;
  padding: 20px;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
  margin: 20px 0;
}

.form-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 15px;
  margin-bottom: 15px;
}

.form-group {
  display: flex;
  flex-direction: column;
}

.form-group label {
  margin-bottom: 5px;
  font-weight: bold;
  color: #333;
}

.form-control {
  padding: 8px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 14px;
}

.form-actions {
  display: flex;
  gap: 10px;
  justify-content: flex-end;
  margin-top: 20px;
}

.btn {
  padding: 8px 16px;
  border: none;
  border-radius: 4px;
  cursor: pointer;
  font-size: 14px;
  font-weight: bold;
}

.btn-primary { background: #007bff; color: white; }
.btn-secondary { background: #6c757d; color: white; }
.btn-success { background: #28a745; color: white; }

@media (max-width: 768px) {
  .form-row {
    grid-template-columns: 1fr;
  }
  
  .form-actions {
    flex-direction: column;
  }
}
</style>