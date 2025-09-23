<template>
  <div class="catalogo-actividades-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Catálogo de Actividades</li>
      </ol>
    </nav>
    <h2>Catálogo de Actividades</h2>
    <div class="mb-3">
      <input v-model="filtro.descripcion" @input="buscarActividades" class="form-control" placeholder="Buscar actividad..." />
    </div>
    <div class="mb-3 text-end">
      <button class="btn btn-primary" @click="abrirFormularioNueva">Agregar Actividad</button>
    </div>
    <table class="table table-bordered table-hover">
      <thead>
        <tr>
          <th>ID</th>
          <th>Giro</th>
          <th>Descripción</th>
          <th>Observaciones</th>
          <th>Estatus</th>
          <th>Alta</th>
          <th>Usuario Alta</th>
          <th>Baja</th>
          <th>Usuario Baja</th>
          <th>Motivo Baja</th>
          <th>Acciones</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="actividad in actividades" :key="actividad.id_actividad">
          <td>{{ actividad.id_actividad }}</td>
          <td>{{ obtenerNombreGiro(actividad.id_giro) }}</td>
          <td>{{ actividad.descripcion }}</td>
          <td>{{ actividad.observaciones }}</td>
          <td>{{ actividad.vigente === 'V' ? 'Vigente' : 'Cancelado' }}</td>
          <td>{{ actividad.fecha_alta ? actividad.fecha_alta.substring(0, 10) : '' }}</td>
          <td>{{ actividad.usuario_alta }}</td>
          <td>{{ actividad.fecha_baja ? actividad.fecha_baja.substring(0, 10) : '' }}</td>
          <td>{{ actividad.usuario_baja }}</td>
          <td>{{ actividad.motivo_baja }}</td>
          <td>
            <button class="btn btn-sm btn-secondary me-1" @click="abrirFormularioEditar(actividad)">Editar</button>
            <button class="btn btn-sm btn-danger" @click="eliminarActividad(actividad)" :disabled="actividad.vigente !== 'V'">Eliminar</button>
          </td>
        </tr>
        <tr v-if="actividades.length === 0">
          <td colspan="11" class="text-center">No hay actividades registradas.</td>
        </tr>
      </tbody>
    </table>

    <!-- Formulario Modal -->
    <div v-if="mostrarFormulario" class="modal-mask">
      <div class="modal-wrapper">
        <div class="modal-container">
          <h3>{{ esEdicion ? 'Editar Actividad' : 'Nueva Actividad' }}</h3>
          <form @submit.prevent="guardarActividad">
            <div class="mb-2">
              <label for="giro">Giro</label>
              <select v-model="form.id_giro" class="form-select" required>
                <option value="">Seleccione un giro</option>
                <option v-for="giro in giros" :key="giro.id_giro" :value="giro.id_giro">{{ giro.descripcion }}</option>
              </select>
            </div>
            <div class="mb-2">
              <label for="descripcion">Descripción</label>
              <input v-model="form.descripcion" class="form-control" required maxlength="250" />
            </div>
            <div class="mb-2">
              <label for="observaciones">Observaciones</label>
              <input v-model="form.observaciones" class="form-control" maxlength="100" />
            </div>
            <div class="mb-2">
              <label for="vigente">Estatus</label>
              <select v-model="form.vigente" class="form-select" required>
                <option value="V">Vigente</option>
                <option value="C">Cancelado</option>
              </select>
            </div>
            <div class="text-end">
              <button type="submit" class="btn btn-success">Guardar</button>
              <button type="button" class="btn btn-secondary" @click="cerrarFormulario">Cancelar</button>
            </div>
          </form>
        </div>
      </div>
    </div>
    <!-- /Formulario Modal -->
  </div>
</template>

<script>
export default {
  name: 'CatalogoActividadesPage',
  data() {
    return {
      actividades: [],
      giros: [],
      filtro: { descripcion: '' },
      mostrarFormulario: false,
      esEdicion: false,
      form: {
        id_actividad: null,
        id_giro: '',
        descripcion: '',
        observaciones: '',
        vigente: 'V'
      }
    };
  },
  created() {
    this.cargarGiros();
    this.buscarActividades();
  },
  methods: {
    async cargarGiros() {
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'catalogo_actividades.giros' })
      });
      const data = await res.json();
      if (data.success) this.giros = data.data;
    },
    async buscarActividades() {
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'catalogo_actividades.list', params: { descripcion: this.filtro.descripcion } })
      });
      const data = await res.json();
      if (data.success) this.actividades = data.data;
    },
    obtenerNombreGiro(id_giro) {
      const giro = this.giros.find(g => g.id_giro === id_giro);
      return giro ? giro.descripcion : id_giro;
    },
    abrirFormularioNueva() {
      this.form = { id_actividad: null, id_giro: '', descripcion: '', observaciones: '', vigente: 'V' };
      this.esEdicion = false;
      this.mostrarFormulario = true;
    },
    abrirFormularioEditar(actividad) {
      this.form = { ...actividad };
      this.esEdicion = true;
      this.mostrarFormulario = true;
    },
    cerrarFormulario() {
      this.mostrarFormulario = false;
    },
    async guardarActividad() {
      const action = this.esEdicion ? 'catalogo_actividades.update' : 'catalogo_actividades.create';
      const params = { ...this.form };
      if (!params.id_giro || !params.descripcion) {
        alert('Debe seleccionar un giro y capturar la descripción.');
        return;
      }
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action, params })
      });
      const data = await res.json();
      if (data.success) {
        this.buscarActividades();
        this.cerrarFormulario();
      } else {
        alert(data.message || 'Error al guardar');
      }
    },
    async eliminarActividad(actividad) {
      if (!confirm('¿Está seguro de eliminar esta actividad?')) return;
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'catalogo_actividades.delete', params: { id: actividad.id_actividad, motivo_baja: 'Eliminación manual' } })
      });
      const data = await res.json();
      if (data.success) {
        this.buscarActividades();
      } else {
        alert(data.message || 'Error al eliminar');
      }
    }
  }
};
</script>

<style scoped>
.catalogo-actividades-page {
  max-width: 1200px;
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
