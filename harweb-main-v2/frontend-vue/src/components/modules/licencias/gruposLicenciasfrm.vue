<template>
  <div class="grupos-licencias-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Grupos de Licencias</li>
      </ol>
    </nav>
    <h1>Grupos de Licencias</h1>
    <div class="mb-3">
      <label for="grupoSearch">Buscar Grupo</label>
      <input id="grupoSearch" v-model="grupoSearch" @input="fetchGrupos" class="form-control" placeholder="Descripción del grupo" />
      <button class="btn btn-primary mt-2" @click="showGrupoForm = true">Agregar Grupo</button>
    </div>
    <div v-if="showGrupoForm" class="card mb-3">
      <div class="card-body">
        <h5 class="card-title">{{ grupoForm.id ? 'Editar Grupo' : 'Agregar Grupo' }}</h5>
        <form @submit.prevent="saveGrupo">
          <div class="mb-2">
            <label>Descripción</label>
            <input v-model="grupoForm.descripcion" class="form-control" required />
          </div>
          <button class="btn btn-success" type="submit">Guardar</button>
          <button class="btn btn-secondary ms-2" type="button" @click="cancelGrupoForm">Cancelar</button>
        </form>
      </div>
    </div>
    <table class="table table-bordered table-hover">
      <thead>
        <tr>
          <th>ID</th>
          <th>Descripción</th>
          <th>Acciones</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="g in grupos" :key="g.id">
          <td>{{ g.id }}</td>
          <td>{{ g.descripcion }}</td>
          <td>
            <button class="btn btn-sm btn-info" @click="editGrupo(g)">Editar</button>
            <button class="btn btn-sm btn-danger ms-2" @click="deleteGrupo(g)">Eliminar</button>
            <button class="btn btn-sm btn-primary ms-2" @click="selectGrupo(g)">Administrar Licencias</button>
          </td>
        </tr>
      </tbody>
    </table>

    <div v-if="selectedGrupo" class="mt-4">
      <h2>Licencias del Grupo: {{ selectedGrupo.descripcion }}</h2>
      <div class="row">
        <div class="col-md-6">
          <h4>Licencias Disponibles</h4>
          <div class="mb-2">
            <label>Filtrar por Giro</label>
            <select v-model="filtroGiro" class="form-select">
              <option value="">Todos</option>
              <option v-for="giro in giros" :key="giro.id_giro" :value="giro.id_giro">{{ giro.descripcion }}</option>
            </select>
          </div>
          <div class="mb-2">
            <label>Filtrar por Actividad o Propietario</label>
            <input v-model="filtroActividad" class="form-control" placeholder="Actividad o Propietario" />
          </div>
          <button class="btn btn-secondary mb-2" @click="fetchLicenciasDisponibles">Buscar</button>
          <table class="table table-sm table-bordered">
            <thead>
              <tr>
                <th></th>
                <th>Licencia</th>
                <th>Propietario</th>
                <th>Actividad</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="l in licenciasDisponibles" :key="l.licencia">
                <td><input type="checkbox" v-model="selectedLicenciasAdd" :value="l.licencia" /></td>
                <td>{{ l.licencia }}</td>
                <td>{{ l.propietarionvo }}</td>
                <td>{{ l.actividad }}</td>
              </tr>
            </tbody>
          </table>
          <button class="btn btn-success" @click="addLicenciasToGrupo">Agregar al Grupo</button>
        </div>
        <div class="col-md-6">
          <h4>Licencias en el Grupo</h4>
          <div class="mb-2">
            <label>Filtrar por Actividad o Propietario</label>
            <input v-model="filtroGrupoActividad" class="form-control" placeholder="Actividad o Propietario" />
          </div>
          <button class="btn btn-secondary mb-2" @click="fetchLicenciasGrupo">Buscar</button>
          <table class="table table-sm table-bordered">
            <thead>
              <tr>
                <th></th>
                <th>Licencia</th>
                <th>Propietario</th>
                <th>Actividad</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="l in licenciasGrupo" :key="l.licencia">
                <td><input type="checkbox" v-model="selectedLicenciasRemove" :value="l.licencia" /></td>
                <td>{{ l.licencia }}</td>
                <td>{{ l.propietarionvo }}</td>
                <td>{{ l.actividad }}</td>
              </tr>
            </tbody>
          </table>
          <button class="btn btn-danger" @click="removeLicenciasFromGrupo">Quitar del Grupo</button>
        </div>
      </div>
      <button class="btn btn-secondary mt-3" @click="selectedGrupo = null">Regresar a Grupos</button>
    </div>
  </div>
</template>

<script>
export default {
  name: 'GruposLicenciasPage',
  data() {
    return {
      grupoSearch: '',
      grupos: [],
      showGrupoForm: false,
      grupoForm: { id: null, descripcion: '' },
      selectedGrupo: null,
      licenciasDisponibles: [],
      licenciasGrupo: [],
      selectedLicenciasAdd: [],
      selectedLicenciasRemove: [],
      filtroGiro: '',
      filtroActividad: '',
      filtroGrupoActividad: '',
      giros: []
    };
  },
  mounted() {
    this.fetchGrupos();
    this.fetchGiros();
  },
  methods: {
    async api(eRequest, params = {}) {
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ eRequest, params })
      });
      const json = await res.json();
      if (!json.eResponse.success) throw new Error(json.eResponse.error || 'Error');
      return json.eResponse.data;
    },
    async fetchGrupos() {
      this.grupos = await this.api('get_grupos_licencias', { descripcion: this.grupoSearch });
    },
    async fetchGiros() {
      this.giros = await this.api('get_giros');
    },
    editGrupo(g) {
      this.grupoForm = { ...g };
      this.showGrupoForm = true;
    },
    cancelGrupoForm() {
      this.grupoForm = { id: null, descripcion: '' };
      this.showGrupoForm = false;
    },
    async saveGrupo() {
      if (this.grupoForm.id) {
        await this.api('update_grupo_licencia', { id: this.grupoForm.id, descripcion: this.grupoForm.descripcion });
      } else {
        await this.api('insert_grupo_licencia', { descripcion: this.grupoForm.descripcion });
      }
      this.cancelGrupoForm();
      this.fetchGrupos();
    },
    async deleteGrupo(g) {
      if (confirm('¿Eliminar grupo?')) {
        await this.api('delete_grupo_licencia', { id: g.id });
        this.fetchGrupos();
      }
    },
    async selectGrupo(g) {
      this.selectedGrupo = g;
      this.filtroGiro = '';
      this.filtroActividad = '';
      this.filtroGrupoActividad = '';
      this.selectedLicenciasAdd = [];
      this.selectedLicenciasRemove = [];
      await this.fetchLicenciasDisponibles();
      await this.fetchLicenciasGrupo();
    },
    async fetchLicenciasDisponibles() {
      this.licenciasDisponibles = await this.api('get_licencias_disponibles', {
        grupo_id: this.selectedGrupo.id,
        actividad: this.filtroActividad,
        id_giro: this.filtroGiro
      });
    },
    async fetchLicenciasGrupo() {
      this.licenciasGrupo = await this.api('get_licencias_grupo', {
        grupo_id: this.selectedGrupo.id,
        actividad: this.filtroGrupoActividad
      });
    },
    async addLicenciasToGrupo() {
      if (!this.selectedLicenciasAdd.length) return alert('Seleccione licencias a agregar');
      await this.api('add_licencias_to_grupo', {
        grupo_id: this.selectedGrupo.id,
        licencias: this.selectedLicenciasAdd
      });
      this.selectedLicenciasAdd = [];
      await this.fetchLicenciasDisponibles();
      await this.fetchLicenciasGrupo();
    },
    async removeLicenciasFromGrupo() {
      if (!this.selectedLicenciasRemove.length) return alert('Seleccione licencias a quitar');
      await this.api('remove_licencias_from_grupo', {
        grupo_id: this.selectedGrupo.id,
        licencias: this.selectedLicenciasRemove
      });
      this.selectedLicenciasRemove = [];
      await this.fetchLicenciasDisponibles();
      await this.fetchLicenciasGrupo();
    }
  }
};
</script>

<style scoped>
.grupos-licencias-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
}
.breadcrumb {
  background: none;
  padding: 0;
  margin-bottom: 1rem;
}
</style>
