<template>
  <div class="cve-cuota-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Claves de Cuota</li>
      </ol>
    </nav>
    <h2>Catálogo de Claves de Cuota</h2>
    <div class="mb-3">
      <button class="btn btn-primary" @click="openCreate">Agregar</button>
    </div>
    <table class="table table-striped">
      <thead>
        <tr>
          <th>Clave</th>
          <th>Descripción</th>
          <th>Acciones</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="item in cveCuotas" :key="item.clave_cuota">
          <td>{{ item.clave_cuota }}</td>
          <td>{{ item.descripcion }}</td>
          <td>
            <button class="btn btn-sm btn-warning" @click="openEdit(item)">Editar</button>
          </td>
        </tr>
      </tbody>
    </table>
    <div v-if="showForm" class="modal-mask">
      <div class="modal-wrapper">
        <div class="modal-container">
          <h3>{{ formMode === 'create' ? 'Agregar Clave de Cuota' : 'Editar Clave de Cuota' }}</h3>
          <form @submit.prevent="submitForm">
            <div class="mb-3">
              <label>Clave de Cuota</label>
              <input type="number" v-model.number="form.clave_cuota" class="form-control" :readonly="formMode==='edit'" required />
            </div>
            <div class="mb-3">
              <label>Descripción</label>
              <input type="text" v-model="form.descripcion" class="form-control" maxlength="50" required />
            </div>
            <div class="mb-3">
              <button type="submit" class="btn btn-success">Guardar</button>
              <button type="button" class="btn btn-secondary" @click="closeForm">Cancelar</button>
            </div>
          </form>
        </div>
      </div>
    </div>
    <div v-if="error" class="alert alert-danger mt-3">{{ error }}</div>
    <div v-if="success" class="alert alert-success mt-3">{{ success }}</div>
  </div>
</template>

<script>
export default {
  name: 'CveCuotaPage',
  data() {
    return {
      cveCuotas: [],
      showForm: false,
      formMode: 'create',
      form: {
        clave_cuota: '',
        descripcion: ''
      },
      error: '',
      success: ''
    };
  },
  mounted() {
    this.fetchCveCuotas();
  },
  methods: {
    async fetchCveCuotas() {
      this.error = '';
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: { action: 'listCveCuota' }
          })
        });
        const data = await res.json();
        if (data.eResponse.success) {
          this.cveCuotas = data.eResponse.data;
        } else {
          this.error = data.eResponse.message;
        }
      } catch (e) {
        this.error = e.message;
      }
    },
    openCreate() {
      this.formMode = 'create';
      this.form = { clave_cuota: '', descripcion: '' };
      this.showForm = true;
      this.error = '';
      this.success = '';
    },
    openEdit(item) {
      this.formMode = 'edit';
      this.form = { clave_cuota: item.clave_cuota, descripcion: item.descripcion };
      this.showForm = true;
      this.error = '';
      this.success = '';
    },
    closeForm() {
      this.showForm = false;
      this.error = '';
      this.success = '';
    },
    async submitForm() {
      this.error = '';
      this.success = '';
      let action = this.formMode === 'create' ? 'createCveCuota' : 'updateCveCuota';
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: {
              action,
              params: {
                clave_cuota: this.form.clave_cuota,
                descripcion: this.form.descripcion
              }
            }
          })
        });
        const data = await res.json();
        if (data.eResponse.success) {
          this.success = data.eResponse.message;
          this.showForm = false;
          this.fetchCveCuotas();
        } else {
          this.error = data.eResponse.message;
        }
      } catch (e) {
        this.error = e.message;
      }
    }
  }
};
</script>

<style scoped>
.cve-cuota-page {
  max-width: 800px;
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
  width: 100%;
  max-width: 400px;
}
.modal-container {
  background: #fff;
  padding: 2rem;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.2);
}
</style>
