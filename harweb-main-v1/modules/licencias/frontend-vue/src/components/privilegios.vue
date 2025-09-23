<template>
  <div class="privilegios-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active">Privilegios de Usuarios</li>
      </ol>
    </nav>
    <h1>Usuarios de Licencias</h1>
    <div class="mb-3">
      <label for="filtro" class="form-label">Buscar usuario o nombre</label>
      <input v-model="filtro" @input="fetchUsuarios" id="filtro" class="form-control" placeholder="Usuario o nombre..." />
    </div>
    <table class="table table-striped">
      <thead>
        <tr>
          <th @click="sortBy('usuario')">Usuario</th>
          <th @click="sortBy('nombres')">Nombre</th>
          <th @click="sortBy('baja')">Baja</th>
          <th @click="sortBy('nombredepto')">Departamento</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="usuario in usuarios" :key="usuario.usuario" @click="selectUsuario(usuario)" :class="{selected: usuario.usuario === selectedUsuario?.usuario}">
          <td>{{ usuario.usuario }}</td>
          <td>{{ usuario.nombres }}</td>
          <td>{{ usuario.baja }}</td>
          <td>{{ usuario.nombredepto }}</td>
        </tr>
      </tbody>
    </table>
    <div v-if="selectedUsuario">
      <h2>Permisos actuales</h2>
      <table class="table table-bordered">
        <thead>
          <tr>
            <th>Num. Tag</th>
            <th>Permiso</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="permiso in permisos" :key="permiso.num_tag">
            <td>{{ permiso.num_tag }}</td>
            <td>{{ permiso.descripcion }}</td>
          </tr>
        </tbody>
      </table>
      <h2>Bitácora de Permisos</h2>
      <table class="table table-bordered">
        <thead>
          <tr>
            <th>Num. Tag</th>
            <th>Descripción</th>
            <th>Movimiento</th>
            <th>Fecha/Hora</th>
            <th>Equipo</th>
            <th>ID</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="aud in auditoria" :key="aud.id">
            <td>{{ aud.num_tag }}</td>
            <td>{{ aud.descripcion }}</td>
            <td>{{ aud.proc }}</td>
            <td>{{ aud.fechahora }}</td>
            <td>{{ aud.equipo }}</td>
            <td>{{ aud.id }}</td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-if="loading" class="text-center my-3">
      <span class="spinner-border"></span> Cargando...
    </div>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>
  </div>
</template>

<script>
export default {
  name: 'PrivilegiosPage',
  data() {
    return {
      filtro: '',
      usuarios: [],
      selectedUsuario: null,
      permisos: [],
      auditoria: [],
      loading: false,
      error: '',
      sortField: 'usuario',
      sortDir: 'asc',
      page: 1,
      perPage: 20
    };
  },
  created() {
    this.fetchUsuarios();
  },
  methods: {
    async fetchUsuarios() {
      this.loading = true;
      this.error = '';
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'licencias2.getUsuariosPrivilegios',
          payload: {
            campo: this.sortField,
            filtro: this.filtro,
            page: this.page,
            perPage: this.perPage
          }
        });
        if (res.data.status === 'success') {
          this.usuarios = res.data.data;
        } else {
          this.error = res.data.message || 'Error al cargar usuarios';
        }
      } catch (error) {
        this.error = error.message;
      } finally {
        this.loading = false;
      }
    },
    async selectUsuario(usuario) {
      this.selectedUsuario = usuario;
      this.permisos = [];
      this.auditoria = [];
      this.loading = true;
      try {
        // Permisos
        const resPerm = await this.$axios.post('/api/execute', {
          action: 'licencias2.getPermisosUsuario',
          payload: { usuario: usuario.usuario }
        });
        if (resPerm.data.status === 'success') {
          this.permisos = resPerm.data.data;
        }
        // Auditoría
        const resAud = await this.$axios.post('/api/execute', {
          action: 'licencias2.getAuditoriaUsuario',
          payload: { usuario: usuario.usuario }
        });
        if (resAud.data.status === 'success') {
          this.auditoria = resAud.data.data;
        }
      } catch (error) {
        this.error = error.message;
      } finally {
        this.loading = false;
      }
    },
    sortBy(field) {
      if (this.sortField === field) {
        this.sortDir = this.sortDir === 'asc' ? 'desc' : 'asc';
      } else {
        this.sortField = field;
        this.sortDir = 'asc';
      }
      this.fetchUsuarios();
    }
  }
};
</script>

<style scoped>
.privilegios-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
}
.selected {
  background: #e6f7ff;
}
.breadcrumb {
  background: none;
  padding: 0;
  margin-bottom: 1rem;
}
</style>
