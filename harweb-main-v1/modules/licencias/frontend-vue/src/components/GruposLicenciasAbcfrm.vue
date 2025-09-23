<template>
  <div class="grupos-licencias-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Grupos de Licencias</li>
      </ol>
    </nav>
    <h2 class="mb-4">Mantenimiento a Grupos de Licencias</h2>
    <div class="mb-3 d-flex align-items-center">
      <label for="filtroDescripcion" class="form-label me-2">Grupo:</label>
      <input
        id="filtroDescripcion"
        v-model="filtroDescripcion"
        @input="buscarGrupos"
        type="text"
        class="form-control"
        style="max-width: 400px;"
        placeholder="Buscar por descripción..."
      />
      <button class="btn btn-primary ms-3" @click="mostrarFormulario('agregar')" :disabled="formVisible">Agregar</button>
    </div>
    <div class="table-responsive mb-4">
      <table class="table table-striped table-bordered">
        <thead>
          <tr>
            <th style="width: 80px;">ID</th>
            <th>Descripción</th>
            <th style="width: 160px;">Acciones</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="grupo in grupos" :key="grupo.id">
            <td>{{ grupo.id }}</td>
            <td>{{ grupo.descripcion }}</td>
            <td>
              <button class="btn btn-sm btn-secondary me-2" @click="mostrarFormulario('editar', grupo)">Editar</button>
              <button class="btn btn-sm btn-danger" @click="eliminarGrupo(grupo.id)">Eliminar</button>
            </td>
          </tr>
          <tr v-if="grupos.length === 0">
            <td colspan="3" class="text-center">No hay grupos encontrados.</td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-if="formVisible" class="card mb-4">
      <div class="card-body">
        <h5 class="card-title mb-3">{{ modoFormulario === 'agregar' ? 'Agregar Grupo' : 'Editar Grupo' }}</h5>
        <form @submit.prevent="guardarGrupo">
          <div class="mb-3">
            <label for="grupoId" class="form-label">ID</label>
            <input
              id="grupoId"
              type="text"
              class="form-control"
              v-model="formulario.id"
              :readonly="true"
              v-if="modoFormulario === 'editar'"
            />
            <span v-else class="form-text">(Se asigna automáticamente)</span>
          </div>
          <div class="mb-3">
            <label for="grupoDescripcion" class="form-label">Descripción</label>
            <input
              id="grupoDescripcion"
              type="text"
              class="form-control"
              v-model="formulario.descripcion"
              required
              maxlength="255"
              style="text-transform: uppercase;"
            />
          </div>
          <div class="d-flex">
            <button type="submit" class="btn btn-success me-2">Aceptar</button>
            <button type="button" class="btn btn-secondary" @click="cancelarFormulario">Cancelar</button>
          </div>
        </form>
      </div>
    </div>
    <div v-if="mensaje" class="alert" :class="{'alert-success': mensajeTipo==='success', 'alert-danger': mensajeTipo==='error'}">
      {{ mensaje }}
    </div>
  </div>
</template>

<script>
export default {
  name: 'GruposLicenciasPage',
  data() {
    return {
      grupos: [],
      filtroDescripcion: '',
      formVisible: false,
      modoFormulario: 'agregar', // 'agregar' | 'editar'
      formulario: {
        id: '',
        descripcion: ''
      },
      mensaje: '',
      mensajeTipo: 'success',
      cargando: false
    };
  },
  mounted() {
    this.buscarGrupos();
  },
  methods: {
    async buscarGrupos() {
      this.cargando = true;
      try {
        const response = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: {
              operation: 'list_grupos_licencias',
              params: { descripcion: this.filtroDescripcion }
            }
          })
        });
        const data = await response.json();
        if (data.eResponse.success) {
          this.grupos = data.eResponse.data;
        } else {
          this.grupos = [];
          this.mostrarMensaje(data.eResponse.message || 'Error al cargar grupos', 'error');
        }
      } catch (e) {
        this.mostrarMensaje('Error de conexión con el servidor', 'error');
      }
      this.cargando = false;
    },
    mostrarFormulario(modo, grupo = null) {
      this.modoFormulario = modo;
      if (modo === 'editar' && grupo) {
        this.formulario = { id: grupo.id, descripcion: grupo.descripcion };
      } else {
        this.formulario = { id: '', descripcion: '' };
      }
      this.formVisible = true;
      this.mensaje = '';
    },
    cancelarFormulario() {
      this.formVisible = false;
      this.formulario = { id: '', descripcion: '' };
      this.mensaje = '';
    },
    async guardarGrupo() {
      if (!this.formulario.descripcion.trim()) {
        this.mostrarMensaje('La descripción es obligatoria', 'error');
        return;
      }
      let operacion = this.modoFormulario === 'agregar' ? 'insert_grupo_licencia' : 'update_grupo_licencia';
      let params = {
        descripcion: this.formulario.descripcion.trim().toUpperCase()
      };
      if (this.modoFormulario === 'editar') {
        params.id = this.formulario.id;
      }
      try {
        const response = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: {
              operation: operacion,
              params
            }
          })
        });
        const data = await response.json();
        if (data.eResponse.success) {
          this.mostrarMensaje('Grupo guardado correctamente', 'success');
          this.cancelarFormulario();
          this.buscarGrupos();
        } else {
          this.mostrarMensaje(data.eResponse.message || 'Error al guardar', 'error');
        }
      } catch (e) {
        this.mostrarMensaje('Error de conexión con el servidor', 'error');
      }
    },
    async eliminarGrupo(id) {
      if (!confirm('¿Está seguro de eliminar este grupo?')) return;
      try {
        const response = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: {
              operation: 'delete_grupo_licencia',
              params: { id }
            }
          })
        });
        const data = await response.json();
        if (data.eResponse.success) {
          this.mostrarMensaje('Grupo eliminado correctamente', 'success');
          this.buscarGrupos();
        } else {
          this.mostrarMensaje(data.eResponse.message || 'Error al eliminar', 'error');
        }
      } catch (e) {
        this.mostrarMensaje('Error de conexión con el servidor', 'error');
      }
    },
    mostrarMensaje(msg, tipo) {
      this.mensaje = msg;
      this.mensajeTipo = tipo;
      setTimeout(() => { this.mensaje = ''; }, 4000);
    }
  }
};
</script>

<style scoped>
.grupos-licencias-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem 1rem;
}
.card {
  max-width: 500px;
  margin: 0 auto;
}
</style>
