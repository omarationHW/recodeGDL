<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="money-bill-wave" /></div>
      <div class="module-view-info">
        <h1>Claves de Cuota</h1>
        <p>Mercados - Claves de Cuota</p>
      </div>
    </div>

    <div class="module-view-content">
    <h2>Catálogo de Claves de Cuota</h2>
    <div class="mb-3">
      <button class="btn-municipal-primary" @click="openCreate">Agregar</button>
    </div>
    <table class="municipal-table">
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
            <button class="btn-icon btn-warning" @click="openEdit(item)">Editar</button>
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
              <input type="number" v-model.number="form.clave_cuota" class="municipal-form-control" :readonly="formMode==='edit'" required />
            </div>
            <div class="mb-3">
              <label>Descripción</label>
              <input type="text" v-model="form.descripcion" class="municipal-form-control" maxlength="50" required />
            </div>
            <div class="mb-3">
              <button type="submit" class="btn-municipal-success">Guardar</button>
              <button type="button" class="btn-municipal-secondary" @click="closeForm">Cancelar</button>
            </div>
          </form>
        </div>
      </div>
    </div>
    <div v-if="error" class="alert alert-danger mt-3">{{ error }}</div>
    <div v-if="success" class="alert alert-success mt-3">{{ success }}</div>
  </div>
    <!-- /module-view-content -->
  </div>
  <!-- /module-view -->
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
        if (data.eResponse.status === 'ok') {
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
        if (data.eResponse.status === 'ok') {
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
