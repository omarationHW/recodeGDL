<template>
  <div>
    <router-view />
  </div>
</template>

<script>
export default {
  name: 'ConsultaUsuariosRoot',
};
</script>

<!--
Below are the three page components for each search type. Each should be placed in its own file and registered in the router.
-->

<!-- UsuarioSearchPage.vue -->
<template>
  <div>
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Consulta por Usuario</li>
      </ol>
    </nav>
    <h2>Consulta de Usuarios por Usuario</h2>
    <form @submit.prevent="buscarUsuario">
      <div class="form-group">
        <label for="usuario">Usuario:</label>
        <input v-model="usuario" id="usuario" class="form-control" type="text" required />
      </div>
      <button class="btn btn-primary" type="submit">Buscar</button>
    </form>
    <div v-if="error" class="alert alert-danger mt-2">{{ error }}</div>
    <div v-if="usuarios.length">
      <h3 class="mt-4">Resultados</h3>
      <UsuariosGrid :usuarios="usuarios" />
    </div>
  </div>
</template>

<script>
import UsuariosGrid from './UsuariosGrid.vue';
export default {
  name: 'UsuarioSearchPage',
  components: { UsuariosGrid },
  data() {
    return {
      usuario: '',
      usuarios: [],
      error: ''
    };
  },
  methods: {
    async buscarUsuario() {
      this.error = '';
      this.usuarios = [];
      if (!this.usuario) {
        this.error = 'Debes indicar el usuario ...';
        return;
      }
      try {
        const res = await this.$axios.post('/api/execute', {
          eRequest: 'consulta_usuario_por_usuario',
          params: { usuario: this.usuario }
        });
        if (res.data.eResponse.success) {
          this.usuarios = res.data.eResponse.data;
        } else {
          this.error = res.data.eResponse.message || 'Error en la consulta';
        }
      } catch (e) {
        this.error = 'Error de red o servidor';
      }
    }
  }
};
</script>

<!-- NombreSearchPage.vue -->
<template>
  <div>
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Consulta por Nombre</li>
      </ol>
    </nav>
    <h2>Consulta de Usuarios por Nombre</h2>
    <form @submit.prevent="buscarNombre">
      <div class="form-group">
        <label for="nombre">Nombre:</label>
        <input v-model="nombre" id="nombre" class="form-control" type="text" required />
      </div>
      <button class="btn btn-primary" type="submit">Buscar</button>
    </form>
    <div v-if="error" class="alert alert-danger mt-2">{{ error }}</div>
    <div v-if="usuarios.length">
      <h3 class="mt-4">Resultados</h3>
      <UsuariosGrid :usuarios="usuarios" />
    </div>
  </div>
</template>

<script>
import UsuariosGrid from './UsuariosGrid.vue';
export default {
  name: 'NombreSearchPage',
  components: { UsuariosGrid },
  data() {
    return {
      nombre: '',
      usuarios: [],
      error: ''
    };
  },
  methods: {
    async buscarNombre() {
      this.error = '';
      this.usuarios = [];
      if (!this.nombre) {
        this.error = 'Debes indicar el nombre ...';
        return;
      }
      try {
        const res = await this.$axios.post('/api/execute', {
          eRequest: 'consulta_usuario_por_nombre',
          params: { nombre: this.nombre }
        });
        if (res.data.eResponse.success) {
          this.usuarios = res.data.eResponse.data;
        } else {
          this.error = res.data.eResponse.message || 'Error en la consulta';
        }
      } catch (e) {
        this.error = 'Error de red o servidor';
      }
    }
  }
};
</script>

<!-- DeptoSearchPage.vue -->
<template>
  <div>
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Consulta por Departamento</li>
      </ol>
    </nav>
    <h2>Consulta de Usuarios por Departamento</h2>
    <form @submit.prevent="buscarDepto">
      <div class="form-group">
        <label for="dependencia">Dependencia:</label>
        <select v-model="id_dependencia" id="dependencia" class="form-control" @change="onDependenciaChange" required>
          <option value="" disabled>Seleccione una dependencia</option>
          <option v-for="dep in dependencias" :key="dep.id_dependencia" :value="dep.id_dependencia">{{ dep.descripcion }}</option>
        </select>
      </div>
      <div class="form-group">
        <label for="depto">Departamento:</label>
        <select v-model="cvedepto" id="depto" class="form-control" required>
          <option value="" disabled>Seleccione un departamento</option>
          <option v-for="depto in deptos" :key="depto.cvedepto" :value="depto.cvedepto">{{ depto.nombredepto }}</option>
        </select>
      </div>
      <button class="btn btn-primary" type="submit">Buscar</button>
    </form>
    <div v-if="error" class="alert alert-danger mt-2">{{ error }}</div>
    <div v-if="usuarios.length">
      <h3 class="mt-4">Resultados</h3>
      <UsuariosGrid :usuarios="usuarios" />
    </div>
  </div>
</template>

<script>
import UsuariosGrid from './UsuariosGrid.vue';
export default {
  name: 'DeptoSearchPage',
  components: { UsuariosGrid },
  data() {
    return {
      id_dependencia: '',
      cvedepto: '',
      dependencias: [],
      deptos: [],
      usuarios: [],
      error: ''
    };
  },
  created() {
    this.fetchDependencias();
  },
  methods: {
    async fetchDependencias() {
      try {
        const res = await this.$axios.post('/api/execute', {
          eRequest: 'get_dependencias'
        });
        if (res.data.eResponse.success) {
          this.dependencias = res.data.eResponse.data;
        }
      } catch (e) {
        this.error = 'Error cargando dependencias';
      }
    },
    async onDependenciaChange() {
      this.cvedepto = '';
      this.deptos = [];
      if (!this.id_dependencia) return;
      try {
        const res = await this.$axios.post('/api/execute', {
          eRequest: 'get_deptos_by_dependencia',
          params: { id_dependencia: this.id_dependencia }
        });
        if (res.data.eResponse.success) {
          this.deptos = res.data.eResponse.data;
        }
      } catch (e) {
        this.error = 'Error cargando departamentos';
      }
    },
    async buscarDepto() {
      this.error = '';
      this.usuarios = [];
      if (!this.id_dependencia || !this.cvedepto) {
        this.error = 'Debes indicar la dependencia y el departamento';
        return;
      }
      try {
        const res = await this.$axios.post('/api/execute', {
          eRequest: 'consulta_usuario_por_depto',
          params: {
            id_dependencia: this.id_dependencia,
            cvedepto: this.cvedepto
          }
        });
        if (res.data.eResponse.success) {
          this.usuarios = res.data.eResponse.data;
        } else {
          this.error = res.data.eResponse.message || 'Error en la consulta';
        }
      } catch (e) {
        this.error = 'Error de red o servidor';
      }
    }
  }
};
</script>

<!-- UsuariosGrid.vue -->
<template>
  <table class="table table-bordered table-striped mt-3">
    <thead>
      <tr>
        <th>Usuario</th>
        <th>Nombre</th>
        <th>Dependencia</th>
        <th>Departamento</th>
        <th>Teléfono</th>
        <th>Fecha Alta</th>
        <th>Fecha Baja</th>
        <th>Fecha Captura</th>
        <th>Capturó</th>
        <th>Vigencia</th>
      </tr>
    </thead>
    <tbody>
      <tr v-for="u in usuarios" :key="u.usuario">
        <td>{{ u.usuario }}</td>
        <td>{{ u.nombres }}</td>
        <td>{{ u.descripcion }}</td>
        <td>{{ u.nombredepto }}</td>
        <td>{{ u.telefono }}</td>
        <td>{{ u.fecalt ? (u.fecalt.substr(0,10)) : '' }}</td>
        <td>{{ u.fecbaj ? (u.fecbaj.substr(0,10)) : '' }}</td>
        <td>{{ u.feccap ? (u.feccap.substr(0,10)) : '' }}</td>
        <td>{{ u.capturo }}</td>
        <td>
          <span v-if="u.fecbaj" class="text-danger">Cancelado</span>
          <span v-else class="text-success">Vigente</span>
        </td>
      </tr>
    </tbody>
  </table>
</template>

<script>
export default {
  name: 'UsuariosGrid',
  props: {
    usuarios: { type: Array, required: true }
  }
};
</script>
