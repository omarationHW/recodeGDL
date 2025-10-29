<template>
  <div class="intereses-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Catálogo de Intereses</li>
      </ol>
    </nav>
    <h2>Catálogo de Intereses</h2>
    <div class="mb-3">
      <button class="btn btn-primary" @click="showCreateForm = true">Agregar Interés</button>
    </div>
    <table class="table table-striped">
      <thead>
        <tr>
          <th>Año</th>
          <th>Mes</th>
          <th>Porcentaje</th>
          <th>Usuario</th>
          <th>Fecha Actualización</th>
          <th>Acciones</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="item in intereses" :key="item.axo + '-' + item.mes">
          <td>{{ item.axo }}</td>
          <td>{{ item.mes }}</td>
          <td>{{ item.porcentaje }}</td>
          <td>{{ item.usuario }}</td>
          <td>{{ formatDate(item.fecha_actual) }}</td>
          <td>
            <button class="btn btn-sm btn-warning" @click="editItem(item)">Editar</button>
            <button class="btn btn-sm btn-danger" @click="deleteItem(item)">Eliminar</button>
          </td>
        </tr>
        <tr v-if="intereses.length === 0">
          <td colspan="6" class="text-center">No hay registros</td>
        </tr>
      </tbody>
    </table>

    <!-- Crear/Editar Formulario -->
    <div v-if="showCreateForm || showEditForm" class="modal-mask">
      <div class="modal-wrapper">
        <div class="modal-container">
          <h3>{{ showEditForm ? 'Editar Interés' : 'Agregar Interés' }}</h3>
          <form @submit.prevent="showEditForm ? updateInteres() : createInteres()">
            <div class="mb-2">
              <label>Año</label>
              <input type="number" v-model.number="form.axo" :disabled="showEditForm" required class="form-control" min="2000" max="2100" />
            </div>
            <div class="mb-2">
              <label>Mes</label>
              <input type="number" v-model.number="form.mes" :disabled="showEditForm" required class="form-control" min="1" max="12" />
            </div>
            <div class="mb-2">
              <label>Porcentaje</label>
              <input type="number" v-model.number="form.porcentaje" step="0.0001" required class="form-control" min="0.01" />
            </div>
            <div class="mb-2">
              <label>ID Usuario</label>
              <input type="number" v-model.number="form.id_usuario" required class="form-control" />
            </div>
            <div class="mb-2 text-danger" v-if="errorMsg">{{ errorMsg }}</div>
            <div class="mb-2">
              <button type="submit" class="btn btn-success">Guardar</button>
              <button type="button" class="btn btn-secondary" @click="closeForm">Cancelar</button>
            </div>
          </form>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'InteresesPage',
  data() {
    return {
      intereses: [],
      showCreateForm: false,
      showEditForm: false,
      form: {
        axo: '',
        mes: '',
        porcentaje: '',
        id_usuario: ''
      },
      errorMsg: ''
    };
  },
  mounted() {
    this.fetchIntereses();
  },
  methods: {
    formatDate(dt) {
      if (!dt) return '';
      return new Date(dt).toLocaleString();
    },
    fetchIntereses() {
      fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          eRequest: { operation: 'list' }
        })
      })
        .then(res => res.json())
        .then(res => {
          if (res.eResponse.success) {
            this.intereses = res.eResponse.data;
          } else {
            this.errorMsg = res.eResponse.message;
          }
        });
    },
    createInteres() {
      this.errorMsg = '';
      fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          eRequest: {
            operation: 'create',
            data: this.form
          }
        })
      })
        .then(res => res.json())
        .then(res => {
          if (res.eResponse.success) {
            this.fetchIntereses();
            this.closeForm();
          } else {
            this.errorMsg = res.eResponse.message;
          }
        });
    },
    editItem(item) {
      this.form = { ...item };
      this.showEditForm = true;
      this.showCreateForm = false;
      this.errorMsg = '';
    },
    updateInteres() {
      this.errorMsg = '';
      fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          eRequest: {
            operation: 'update',
            data: this.form
          }
        })
      })
        .then(res => res.json())
        .then(res => {
          if (res.eResponse.success) {
            this.fetchIntereses();
            this.closeForm();
          } else {
            this.errorMsg = res.eResponse.message;
          }
        });
    },
    deleteItem(item) {
      if (!confirm('¿Está seguro de eliminar este registro?')) return;
      fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          eRequest: {
            operation: 'delete',
            data: { axo: item.axo, mes: item.mes }
          }
        })
      })
        .then(res => res.json())
        .then(res => {
          if (res.eResponse.success) {
            this.fetchIntereses();
          } else {
            this.errorMsg = res.eResponse.message;
          }
        });
    },
    closeForm() {
      this.showCreateForm = false;
      this.showEditForm = false;
      this.form = { axo: '', mes: '', porcentaje: '', id_usuario: '' };
      this.errorMsg = '';
    }
  }
};
</script>

<style scoped>
.intereses-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem;
}
.modal-mask {
  position: fixed;
  z-index: 9998;
  top: 0; left: 0; right: 0; bottom: 0;
  background-color: rgba(0,0,0,0.5);
  display: flex;
  align-items: center;
  justify-content: center;
}
.modal-wrapper {
  width: 400px;
  background: #fff;
  border-radius: 8px;
  padding: 2rem;
  box-shadow: 0 2px 8px rgba(0,0,0,0.2);
}
</style>
