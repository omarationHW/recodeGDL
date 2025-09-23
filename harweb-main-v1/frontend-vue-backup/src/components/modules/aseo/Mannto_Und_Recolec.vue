<template>
  <div class="page-container">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Catálogo Unidades de Recolección</li>
      </ol>
    </nav>
    <h2>Catálogo de Unidades de Recolección</h2>
    <div class="actions mb-3">
      <button class="btn btn-primary" @click="showForm('insert')">Agregar Unidad</button>
    </div>
    <table class="table table-bordered table-hover">
      <thead>
        <tr>
          <th>Control</th>
          <th>Ejercicio</th>
          <th>Clave</th>
          <th>Descripción</th>
          <th>Costo Unidad</th>
          <th>Costo Excedente</th>
          <th>Acciones</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="unidad in unidades" :key="unidad.ctrol_recolec">
          <td>{{ unidad.ctrol_recolec }}</td>
          <td>{{ unidad.ejercicio_recolec }}</td>
          <td>{{ unidad.cve_recolec }}</td>
          <td>{{ unidad.descripcion }}</td>
          <td>{{ unidad.costo_unidad }}</td>
          <td>{{ unidad.costo_exed }}</td>
          <td>
            <button class="btn btn-sm btn-warning" @click="showForm('update', unidad)">Editar</button>
            <button class="btn btn-sm btn-danger" @click="showForm('delete', unidad)">Eliminar</button>
          </td>
        </tr>
      </tbody>
    </table>

    <!-- Modal Form -->
    <div v-if="modalVisible" class="modal-backdrop">
      <div class="modal-form">
        <h4 v-if="formMode==='insert'">Agregar Unidad</h4>
        <h4 v-if="formMode==='update'">Editar Unidad</h4>
        <h4 v-if="formMode==='delete'">Eliminar Unidad</h4>
        <form @submit.prevent="submitForm">
          <div v-if="formMode!=='delete'">
            <div class="form-group">
              <label>Ejercicio</label>
              <input type="number" v-model="form.ejercicio" class="form-control" :disabled="formMode!=='insert'" required />
            </div>
            <div class="form-group">
              <label>Clave</label>
              <input type="text" v-model="form.cve" maxlength="1" class="form-control" :disabled="formMode!=='insert'" required />
            </div>
            <div class="form-group">
              <label>Descripción</label>
              <input type="text" v-model="form.descripcion" maxlength="80" class="form-control" required />
            </div>
            <div class="form-group">
              <label>Costo Unidad</label>
              <input type="number" step="0.01" v-model="form.costo" class="form-control" required />
            </div>
            <div class="form-group">
              <label>Costo Excedente</label>
              <input type="number" step="0.01" v-model="form.costo_exed" class="form-control" required />
            </div>
          </div>
          <div v-else>
            <p>¿Está seguro que desea eliminar la unidad <b>{{ form.ctrol_recolec }}</b>?</p>
          </div>
          <div class="form-group mt-3">
            <button type="submit" class="btn btn-success">Aceptar</button>
            <button type="button" class="btn btn-secondary" @click="closeModal">Cancelar</button>
          </div>
          <div v-if="formError" class="alert alert-danger mt-2">{{ formError }}</div>
        </form>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ManntoUndRecolecPage',
  data() {
    return {
      unidades: [],
      modalVisible: false,
      formMode: 'insert', // insert|update|delete
      form: {
        ctrol_recolec: null,
        ejercicio: '',
        cve: '',
        descripcion: '',
        costo: '',
        costo_exed: ''
      },
      formError: ''
    }
  },
  mounted() {
    this.loadUnidades();
  },
  methods: {
    async loadUnidades() {
      // Suponiendo que el ejercicio se obtiene de algún contexto global
      const ejercicio = new Date().getFullYear();
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'list', data: { ejercicio } })
      });
      const json = await res.json();
      if (json.success) {
        this.unidades = json.data;
      } else {
        this.unidades = [];
      }
    },
    showForm(mode, unidad = null) {
      this.formMode = mode;
      this.formError = '';
      if (mode === 'insert') {
        this.form = {
          ctrol_recolec: null,
          ejercicio: new Date().getFullYear(),
          cve: '',
          descripcion: '',
          costo: '',
          costo_exed: ''
        };
      } else if (unidad) {
        this.form = {
          ctrol_recolec: unidad.ctrol_recolec,
          ejercicio: unidad.ejercicio_recolec,
          cve: unidad.cve_recolec,
          descripcion: unidad.descripcion,
          costo: unidad.costo_unidad,
          costo_exed: unidad.costo_exed
        };
      }
      this.modalVisible = true;
    },
    closeModal() {
      this.modalVisible = false;
      this.formError = '';
    },
    async submitForm() {
      let action = this.formMode;
      let payload = {};
      if (action === 'insert') {
        payload = {
          ejercicio: this.form.ejercicio,
          cve: this.form.cve,
          descripcion: this.form.descripcion,
          costo: this.form.costo,
          costo_exed: this.form.costo_exed
        };
      } else if (action === 'update') {
        payload = {
          ctrol_recolec: this.form.ctrol_recolec,
          descripcion: this.form.descripcion,
          costo: this.form.costo,
          costo_exed: this.form.costo_exed
        };
      } else if (action === 'delete') {
        payload = {
          ctrol_recolec: this.form.ctrol_recolec
        };
      }
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action, data: payload })
      });
      const json = await res.json();
      if (json.success) {
        this.closeModal();
        this.loadUnidades();
      } else {
        this.formError = json.message || 'Error en la operación';
      }
    }
  }
}
</script>

<style scoped>
.page-container {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem;
}
.modal-backdrop {
  position: fixed;
  top: 0; left: 0; right: 0; bottom: 0;
  background: rgba(0,0,0,0.3);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}
.modal-form {
  background: #fff;
  padding: 2rem;
  border-radius: 8px;
  min-width: 350px;
  max-width: 400px;
  box-shadow: 0 2px 16px rgba(0,0,0,0.2);
}
</style>
