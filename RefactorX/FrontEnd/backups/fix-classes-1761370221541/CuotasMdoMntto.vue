<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="money-bill-wave" /></div>
      <div class="module-view-info">
        <h1>Cuotas de Mercado por Año</h1>
        <p>Mercados - Cuotas de Mercado por Año</p>
      </div>
    </div>

    <div class="module-view-content">
    <h2>Mantenimiento a Cuotas de Mercados por Año</h2>
    <form @submit.prevent="onSubmit" class="mb-4">
      <div class="row">
        <div class="col-md-2">
          <label for="control">Control</label>
          <input v-model="form.id_cuotas" type="number" class="municipal-form-control" id="control" :readonly="mode==='edit'" />
        </div>
        <div class="col-md-2">
          <label for="axo">Año</label>
          <input v-model="form.axo" type="number" class="municipal-form-control" id="axo" min="1992" max="2999" required />
        </div>
        <div class="col-md-4">
          <label for="categoria">Categoría</label>
          <select v-model="form.categoria" class="municipal-form-control" id="categoria" required>
            <option v-for="cat in catalogs.categorias" :key="cat.categoria" :value="cat.categoria">
              {{ cat.categoria }} - {{ cat.descripcion }}
            </option>
          </select>
        </div>
        <div class="col-md-4">
          <label for="seccion">Sección</label>
          <select v-model="form.seccion" class="municipal-form-control" id="seccion" required>
            <option v-for="sec in catalogs.secciones" :key="sec.seccion" :value="sec.seccion">
              {{ sec.seccion }} - {{ sec.descripcion }}
            </option>
          </select>
        </div>
      </div>
      <div class="row mt-3">
        <div class="col-md-6">
          <label for="clave_cuota">Clave de Cuota</label>
          <select v-model="form.clave_cuota" class="municipal-form-control" id="clave_cuota" required>
            <option v-for="cve in catalogs.claves" :key="cve.clave_cuota" :value="cve.clave_cuota">
              {{ cve.clave_cuota }} - {{ cve.descripcion }}
            </option>
          </select>
        </div>
        <div class="col-md-6">
          <label for="importe">Cuota</label>
          <input v-model.number="form.importe" type="number" step="0.01" min="0.01" class="municipal-form-control" id="importe" required />
        </div>
      </div>
      <div class="mt-4">
        <button type="submit" class="btn btn-primary me-2">{{ mode==='edit' ? 'Actualizar' : 'Crear' }}</button>
        <button type="button" class="btn-municipal-secondary" @click="resetForm">Cancelar</button>
      </div>
      <div v-if="error" class="alert alert-danger mt-3">{{ error }}</div>
      <div v-if="success" class="alert alert-success mt-3">{{ success }}</div>
    </form>
    <h3>Listado de Cuotas</h3>
    <table class="municipal-table">
      <thead>
        <tr>
          <th>Control</th>
          <th>Año</th>
          <th>Categoría</th>
          <th>Sección</th>
          <th>Clave Cuota</th>
          <th>Importe</th>
          <th>Fecha Alta</th>
          <th>Usuario</th>
          <th>Acciones</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="row in cuotas" :key="row.id_cuotas">
          <td>{{ row.id_cuotas }}</td>
          <td>{{ row.axo }}</td>
          <td>{{ row.categoria }}</td>
          <td>{{ row.seccion }}</td>
          <td>{{ row.clave_cuota }}</td>
          <td>{{ row.importe_cuota }}</td>
          <td>{{ row.fecha_alta ? (row.fecha_alta.substr(0,10)) : '' }}</td>
          <td>{{ row.id_usuario }}</td>
          <td>
            <button class="btn btn-sm btn-info me-1" @click="editRow(row)">Editar</button>
            <button class="btn-icon btn-danger" @click="deleteRow(row)">Eliminar</button>
          </td>
        </tr>
      </tbody>
    </table>
  </div>
    <!-- /module-view-content -->
  </div>
  <!-- /module-view -->
</template>

<script>
export default {
  name: 'CuotasMdoMnttoPage',
  data() {
    return {
      cuotas: [],
      catalogs: { categorias: [], secciones: [], claves: [] },
      form: {
        id_cuotas: '',
        axo: '',
        categoria: '',
        seccion: '',
        clave_cuota: '',
        importe: '',
        id_usuario: 1 // Simulación, reemplazar por usuario logueado
      },
      mode: 'create',
      error: '',
      success: ''
    }
  },
  mounted() {
    this.loadCatalogs();
    this.loadCuotas();
  },
  methods: {
    async api(action, data = {}) {
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ eRequest: { action, data } })
      });
      return (await res.json()).eResponse;
    },
    async loadCatalogs() {
      const resp = await this.api('catalogs');
      if (resp.success) {
        this.catalogs = resp.data;
      }
    },
    async loadCuotas() {
      const resp = await this.api('list');
      if (resp.success) {
        this.cuotas = resp.data;
      }
    },
    async onSubmit() {
      this.error = '';
      this.success = '';
      let action = this.mode === 'edit' ? 'update' : 'create';
      let payload = { ...this.form };
      if (this.mode === 'edit') {
        payload.id_cuotas = Number(payload.id_cuotas);
      }
      const resp = await this.api(action, payload);
      if (resp.success) {
        this.success = resp.message;
        this.resetForm();
        this.loadCuotas();
      } else {
        this.error = resp.message;
      }
    },
    editRow(row) {
      this.form = {
        id_cuotas: row.id_cuotas,
        axo: row.axo,
        categoria: row.categoria,
        seccion: row.seccion,
        clave_cuota: row.clave_cuota,
        importe: row.importe_cuota,
        id_usuario: row.id_usuario
      };
      this.mode = 'edit';
      this.error = '';
      this.success = '';
    },
    async deleteRow(row) {
      if (!confirm('¿Está seguro de eliminar este registro?')) return;
      const resp = await this.api('delete', { id_cuotas: row.id_cuotas });
      if (resp.success) {
        this.success = resp.message;
        this.loadCuotas();
      } else {
        this.error = resp.message;
      }
    },
    resetForm() {
      this.form = {
        id_cuotas: '',
        axo: '',
        categoria: '',
        seccion: '',
        clave_cuota: '',
        importe: '',
        id_usuario: 1
      };
      this.mode = 'create';
      this.error = '';
      this.success = '';
    }
  }
}
</script>

<style scoped>
.cuotas-mdo-mntto-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem;
}
</style>
