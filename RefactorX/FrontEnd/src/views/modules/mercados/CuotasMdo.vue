<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="money-bill-wave" /></div>
      <div class="module-view-info">
        <h1>Cuotas de Mercados</h1>
        <p>Mercados - Cuotas de Mercados</p>
      </div>
    </div>

    <div class="module-view-content">
    <h2>Cuotas de Mercados</h2>
    <div class="mb-3 d-flex align-items-center">
      <label class="municipal-form-label me-2">Año:</label>
      <input type="number" v-model="axo" class="municipal-form-control w-auto" min="2000" max="2100" />
      <button class="btn btn-municipal-primary ms-2" @click="fetchCuotas">Buscar</button>
      <button class="btn btn-municipal-success ms-2" @click="showCreate = true">Agregar</button>
    </div>
    <table class="-striped municipal-table-bordered">
      <thead>
        <tr>
          <th>Año</th>
          <th>Categoría</th>
          <th>Sección</th>
          <th>Clave Cuota</th>
          <th>Descripción</th>
          <th>Importe</th>
          <th>Fecha Alta</th>
          <th>Usuario</th>
          <th>Acciones</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="cuota in cuotas" :key="cuota.id_cuotas">
          <td>{{ cuota.axo }}</td>
          <td>{{ cuota.categoria }}</td>
          <td>{{ cuota.seccion }}</td>
          <td>{{ cuota.clave_cuota }}</td>
          <td>{{ cuota.descripcion }}</td>
          <td>{{ cuota.importe_cuota | currency }}</td>
          <td>{{ cuota.fecha_alta | date }}</td>
          <td>{{ cuota.usuario }}</td>
          <td>
            <button class="btn-icon btn-municipal-warning" @click="editCuota(cuota)">Editar</button>
            <button class="btn btn-sm btn-municipal-danger ms-1" @click="deleteCuota(cuota)">Eliminar</button>
          </td>
        </tr>
      </tbody>
    </table>

    <!-- Crear/Editar Modal -->
    <div v-if="showCreate || showEdit" class="modal-mask">
      <div class="modal-wrapper">
        <div class="modal-container">
          <h3>{{ showEdit ? 'Editar Cuota' : 'Agregar Cuota' }}</h3>
          <form @submit.prevent="showEdit ? updateCuota() : createCuota()">
            <div class="mb-2">
              <label class="municipal-form-label">Año</label>
              <input type="number" v-model="form.axo" class="municipal-form-control" required min="2000" max="2100" />
            </div>
            <div class="mb-2">
              <label class="municipal-form-label">Categoría</label>
              <select v-model="form.categoria" class="municipal-form-control" required>
                <option v-for="cat in categorias" :key="cat.categoria" :value="cat.categoria">{{ cat.categoria }} - {{ cat.descripcion }}</option>
              </select>
            </div>
            <div class="mb-2">
              <label class="municipal-form-label">Sección</label>
              <select v-model="form.seccion" class="municipal-form-control" required>
                <option v-for="sec in secciones" :key="sec.seccion" :value="sec.seccion">{{ sec.seccion }} - {{ sec.descripcion }}</option>
              </select>
            </div>
            <div class="mb-2">
              <label class="municipal-form-label">Clave Cuota</label>
              <select v-model="form.clave_cuota" class="municipal-form-control" required>
                <option v-for="cve in clavesCuota" :key="cve.clave_cuota" :value="cve.clave_cuota">{{ cve.clave_cuota }} - {{ cve.descripcion }}</option>
              </select>
            </div>
            <div class="mb-2">
              <label class="municipal-form-label">Importe</label>
              <input type="number" v-model="form.importe_cuota" class="municipal-form-control" required min="0.01" step="0.01" />
            </div>
            <div class="mb-2">
              <label class="municipal-form-label">Usuario</label>
              <input type="number" v-model="form.id_usuario" class="municipal-form-control" required />
            </div>
            <div class="d-flex justify-content-end">
              <button class="btn btn-municipal-secondary me-2" type="button" @click="closeModal">Cancelar</button>
              <button class="btn-municipal-primary" type="submit">{{ showEdit ? 'Actualizar' : 'Guardar' }}</button>
            </div>
          </form>
        </div>
      </div>
    </div>

  </div>
    <!-- /module-view-content -->
  </div>
  <!-- /module-view -->
</template>

<script>
export default {
  name: 'CuotasMdoPage',
  data() {
    return {
      axo: new Date().getFullYear(),
      cuotas: [],
      categorias: [],
      secciones: [],
      clavesCuota: [],
      showCreate: false,
      showEdit: false,
      form: {
        id_cuotas: null,
        axo: '',
        categoria: '',
        seccion: '',
        clave_cuota: '',
        importe_cuota: '',
        id_usuario: ''
      }
    }
  },
  mounted() {
    this.fetchCuotas();
    this.fetchCategorias();
    this.fetchSecciones();
    this.fetchClavesCuota();
  },
  methods: {
    async fetchCuotas() {
      const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
        action: 'list_cuotas',
        params: { axo: this.axo }
      });
      if (res.data.success) {
        this.cuotas = res.data.data;
      }
    },
    async fetchCategorias() {
      const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
        action: 'get_categorias'
      });
      if (res.data.success) {
        this.categorias = res.data.data;
      }
    },
    async fetchSecciones() {
      const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
        action: 'get_secciones'
      });
      if (res.data.success) {
        this.secciones = res.data.data;
      }
    },
    async fetchClavesCuota() {
      const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
        action: 'get_claves_cuota'
      });
      if (res.data.success) {
        this.clavesCuota = res.data.data;
      }
    },
    closeModal() {
      this.showCreate = false;
      this.showEdit = false;
      this.resetForm();
    },
    resetForm() {
      this.form = {
        id_cuotas: null,
        axo: '',
        categoria: '',
        seccion: '',
        clave_cuota: '',
        importe_cuota: '',
        id_usuario: ''
      };
    },
    async createCuota() {
      const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
        action: 'create_cuota',
        params: this.form
      });
      if (res.data.success) {
        this.closeModal();
        this.fetchCuotas();
      } else {
        alert(res.data.message || 'Error al crear cuota');
      }
    },
    editCuota(cuota) {
      this.form = { ...cuota };
      this.showEdit = true;
    },
    async updateCuota() {
      const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
        action: 'update_cuota',
        params: this.form
      });
      if (res.data.success) {
        this.closeModal();
        this.fetchCuotas();
      } else {
        alert(res.data.message || 'Error al actualizar cuota');
      }
    },
    async deleteCuota(cuota) {
      if (!confirm('¿Está seguro de eliminar la cuota seleccionada?')) return;
      const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
        action: 'delete_cuota',
        params: { id_cuotas: cuota.id_cuotas }
      });
      if (res.data.success) {
        this.fetchCuotas();
      } else {
        alert(res.data.message || 'Error al eliminar cuota');
      }
    }
  },
  filters: {
    currency(val) {
      return Number(val).toLocaleString('es-MX', { style: 'currency', currency: 'MXN' });
    },
    date(val) {
      if (!val) return '';
      return new Date(val).toLocaleDateString();
    }
  }
}
</script>

<style scoped>
.cuotas-mdo-page {
  max-width: 1100px;
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
  max-width: 500px;
}
.modal-container {
  background: #fff;
  padding: 2rem;
  border-radius: 8px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.2);
}
</style>
