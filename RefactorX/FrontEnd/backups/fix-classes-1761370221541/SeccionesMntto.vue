<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="file-alt" /></div>
      <div class="module-view-info">
        <h1>Mantenimiento a Secciones</h1>
        <p>Mercados - Mantenimiento a Secciones</p>
      </div>
    </div>

    <div class="module-view-content">
    <div class="municipal-card">
      <div class="municipal-card-header">
        <h4>Mantenimiento a Secciones</h4>
      </div>
      <div class="municipal-card-body">
        <form @submit.prevent="onSubmit">
          <div class="row mb-3">
            <div class="col-md-2">
              <label for="seccion" class="municipal-form-label">Sección</label>
              <input v-model="form.seccion" id="seccion" maxlength="2" class="municipal-form-control" :disabled="mode==='edit'" required />
            </div>
            <div class="col-md-8">
              <label for="descripcion" class="municipal-form-label">Descripción</label>
              <input v-model="form.descripcion" id="descripcion" maxlength="30" class="municipal-form-control" required />
            </div>
          </div>
          <div class="mb-3">
            <button type="submit" class="btn btn-primary me-2">{{ mode==='edit' ? 'Actualizar' : 'Agregar' }}</button>
            <button type="button" class="btn-municipal-secondary" @click="resetForm">Cancelar</button>
          </div>
        </form>
        <hr />
        <h5>Listado de Secciones</h5>
        <table class="municipal-table">
          <thead>
            <tr>
              <th>Sección</th>
              <th>Descripción</th>
              <th style="width:120px">Acciones</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="item in secciones" :key="item.seccion">
              <td>{{ item.seccion }}</td>
              <td>{{ item.descripcion }}</td>
              <td>
                <button class="btn btn-sm btn-info me-1" @click="editSeccion(item)">Editar</button>
              </td>
            </tr>
            <tr v-if="secciones.length===0">
              <td colspan="3" class="text-center">No hay secciones registradas.</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
    <div v-if="alert.message" :class="['alert', alert.success ? 'alert-success' : 'alert-danger', 'mt-3']">
      {{ alert.message }}
    </div>
  </div>
    <!-- /module-view-content -->
  </div>
  <!-- /module-view -->
</template>

<script>
export default {
  name: 'SeccionesMnttoPage',
  data() {
    return {
      secciones: [],
      form: {
        seccion: '',
        descripcion: ''
      },
      mode: 'add', // 'add' or 'edit'
      alert: {
        message: '',
        success: true
      }
    };
  },
  mounted() {
    this.loadSecciones();
  },
  methods: {
    async loadSecciones() {
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ action: 'getAllSecciones' })
        });
        const json = await res.json();
        if (json.success) {
          this.secciones = json.data;
        } else {
          this.alert.message = json.message || 'Error al cargar secciones';
          this.alert.success = false;
        }
      } catch (e) {
        this.alert.message = 'Error de red al cargar secciones';
        this.alert.success = false;
      }
    },
    async onSubmit() {
      if (!this.form.seccion || !this.form.descripcion) {
        this.alert.message = 'Todos los campos son obligatorios';
        this.alert.success = false;
        return;
      }
      const action = this.mode === 'edit' ? 'updateSeccion' : 'insertSeccion';
      const payload = {
        action,
        data: {
          seccion: this.form.seccion.trim().toUpperCase(),
          descripcion: this.form.descripcion.trim().toUpperCase()
        }
      };
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify(payload)
        });
        const json = await res.json();
        if (json.success) {
          this.alert.message = json.message || (this.mode==='edit' ? 'Sección actualizada' : 'Sección agregada');
          this.alert.success = true;
          this.resetForm();
          this.loadSecciones();
        } else {
          this.alert.message = json.message || 'Error en la operación';
          this.alert.success = false;
        }
      } catch (e) {
        this.alert.message = 'Error de red en la operación';
        this.alert.success = false;
      }
    },
    editSeccion(item) {
      this.form.seccion = item.seccion;
      this.form.descripcion = item.descripcion;
      this.mode = 'edit';
    },
    resetForm() {
      this.form.seccion = '';
      this.form.descripcion = '';
      this.mode = 'add';
      this.alert.message = '';
    }
  }
};
</script>

<style scoped>
.secciones-mntto-page {
  max-width: 800px;
  margin: 0 auto;
  padding: 2rem 0;
}
.card {
  box-shadow: 0 2px 8px rgba(0,0,0,0.05);
}
</style>
