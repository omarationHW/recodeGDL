<template>
  <div class="busqueda-formulario">
    <h1>Búsqueda Catastral</h1>
    <nav class="breadcrumb">
      <span @click="goHome">Inicio</span> /
      <span>Búsqueda</span>
    </nav>
    <div class="busqueda-menu">
      <button @click="setFormulario('nombre')">Por Nombre</button>
      <button @click="setFormulario('ubicacion')">Por Ubicación</button>
      <button @click="setFormulario('clave')">Por Clave Catastral</button>
      <button @click="setFormulario('rfc')">Por RFC</button>
      <button @click="setFormulario('cuenta')">Por Cuenta</button>
    </div>
    <div v-if="formulario === 'nombre'">
      <h2>Búsqueda por Nombre</h2>
      <form @submit.prevent="buscarPorNombre">
        <label>Nombre completo del propietario:</label>
        <input v-model="nombre" required placeholder="Ej: JUAN PEREZ" />
        <button type="submit">Buscar</button>
      </form>
    </div>
    <div v-if="formulario === 'ubicacion'">
      <h2>Búsqueda por Ubicación</h2>
      <form @submit.prevent="buscarPorUbicacion">
        <label>Calle:</label>
        <input v-model="calle" required placeholder="Ej: AV. JUAREZ" />
        <label>No. Exterior:</label>
        <input v-model="exterior" placeholder="Ej: 123" />
        <button type="submit">Buscar</button>
      </form>
    </div>
    <div v-if="formulario === 'clave'">
      <h2>Búsqueda por Clave Catastral</h2>
      <form @submit.prevent="buscarPorClaveCatastral">
        <label>Zona:</label>
        <input v-model="zona" required maxlength="5" />
        <label>Manzana:</label>
        <input v-model="manzana" required maxlength="3" />
        <label>Predio:</label>
        <input v-model="predio" maxlength="4" />
        <label>Subpredio:</label>
        <input v-model="subpredio" maxlength="3" />
        <button type="submit">Buscar</button>
      </form>
    </div>
    <div v-if="formulario === 'rfc'">
      <h2>Búsqueda por RFC</h2>
      <form @submit.prevent="buscarPorRFC">
        <label>RFC:</label>
        <input v-model="rfc" required maxlength="13" />
        <button type="submit">Buscar</button>
      </form>
    </div>
    <div v-if="formulario === 'cuenta'">
      <h2>Búsqueda por Cuenta</h2>
      <form @submit.prevent="buscarPorCuenta">
        <label>Recaudadora:</label>
        <input v-model.number="recaud" required type="number" />
        <label>Urbano/Rústico:</label>
        <input v-model="urbrus" required maxlength="1" />
        <label>Cuenta:</label>
        <input v-model.number="cuenta" required type="number" />
        <button type="submit">Buscar</button>
      </form>
    </div>
    <div v-if="loading" class="loading">Buscando...</div>
    <div v-if="error" class="error">{{ error }}</div>
    <div v-if="resultados && resultados.length">
      <h3>Resultados</h3>
      <table class="resultados">
        <thead>
          <tr>
            <th v-for="col in columnas" :key="col">{{ col }}</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(row, idx) in resultados" :key="idx">
            <td v-for="col in columnas" :key="col">{{ row[col] }}</td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-if="resultados && resultados.length === 0">
      <p>No se encontraron resultados.</p>
    </div>
  </div>
</template>

<script>
export default {
  name: 'BusquedaCatastral',
  data() {
    return {
      formulario: 'nombre',
      nombre: '',
      calle: '',
      exterior: '',
      zona: '',
      manzana: '',
      predio: '',
      subpredio: '',
      rfc: '',
      recaud: '',
      urbrus: '',
      cuenta: '',
      resultados: null,
      columnas: [],
      loading: false,
      error: ''
    };
  },
  methods: {
    setFormulario(tipo) {
      this.formulario = tipo;
      this.resultados = null;
      this.error = '';
    },
    goHome() {
      this.$router.push('/');
    },
    async buscarPorNombre() {
      this.loading = true;
      this.error = '';
      this.resultados = null;
      try {
        const resp = await this.$axios.post('/api/execute', {
          eRequest: {
            action: 'buscar_por_nombre',
            params: { nombre: this.nombre }
          }
        });
        this.handleResponse(resp.data.eResponse);
      } catch (e) {
        this.error = 'Error de comunicación con el servidor.';
      } finally {
        this.loading = false;
      }
    },
    async buscarPorUbicacion() {
      this.loading = true;
      this.error = '';
      this.resultados = null;
      try {
        const resp = await this.$axios.post('/api/execute', {
          eRequest: {
            action: 'buscar_por_ubicacion',
            params: { calle: this.calle, exterior: this.exterior }
          }
        });
        this.handleResponse(resp.data.eResponse);
      } catch (e) {
        this.error = 'Error de comunicación con el servidor.';
      } finally {
        this.loading = false;
      }
    },
    async buscarPorClaveCatastral() {
      this.loading = true;
      this.error = '';
      this.resultados = null;
      try {
        const resp = await this.$axios.post('/api/execute', {
          eRequest: {
            action: 'buscar_por_clave_catastral',
            params: {
              zona: this.zona,
              manzana: this.manzana,
              predio: this.predio,
              subpredio: this.subpredio
            }
          }
        });
        this.handleResponse(resp.data.eResponse);
      } catch (e) {
        this.error = 'Error de comunicación con el servidor.';
      } finally {
        this.loading = false;
      }
    },
    async buscarPorRFC() {
      this.loading = true;
      this.error = '';
      this.resultados = null;
      try {
        const resp = await this.$axios.post('/api/execute', {
          eRequest: {
            action: 'buscar_por_rfc',
            params: { rfc: this.rfc }
          }
        });
        this.handleResponse(resp.data.eResponse);
      } catch (e) {
        this.error = 'Error de comunicación con el servidor.';
      } finally {
        this.loading = false;
      }
    },
    async buscarPorCuenta() {
      this.loading = true;
      this.error = '';
      this.resultados = null;
      try {
        const resp = await this.$axios.post('/api/execute', {
          eRequest: {
            action: 'buscar_por_cuenta',
            params: {
              recaud: this.recaud,
              urbrus: this.urbrus,
              cuenta: this.cuenta
            }
          }
        });
        this.handleResponse(resp.data.eResponse);
      } catch (e) {
        this.error = 'Error de comunicación con el servidor.';
      } finally {
        this.loading = false;
      }
    },
    handleResponse(eResponse) {
      if (eResponse.success) {
        this.resultados = eResponse.data;
        if (this.resultados && this.resultados.length > 0) {
          this.columnas = Object.keys(this.resultados[0]);
        } else {
          this.columnas = [];
        }
      } else {
        this.resultados = [];
        this.error = eResponse.error || 'No se encontraron resultados.';
      }
    }
  }
};
</script>

<style scoped>
.busqueda-formulario {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem;
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 8px #0001;
}
.busqueda-menu {
  margin-bottom: 2rem;
}
.busqueda-menu button {
  margin-right: 1rem;
  padding: 0.5rem 1.5rem;
  font-weight: bold;
}
form label {
  display: block;
  margin-top: 1rem;
}
form input {
  width: 100%;
  padding: 0.5rem;
  margin-top: 0.25rem;
  border: 1px solid #ccc;
  border-radius: 4px;
}
.loading {
  color: #007bff;
  font-weight: bold;
  margin: 1rem 0;
}
.error {
  color: #c00;
  font-weight: bold;
  margin: 1rem 0;
}
.resultados {
  width: 100%;
  border-collapse: collapse;
  margin-top: 2rem;
}
.resultados th, .resultados td {
  border: 1px solid #ccc;
  padding: 0.5rem;
}
.breadcrumb {
  margin-bottom: 1rem;
  color: #888;
}
.breadcrumb span {
  cursor: pointer;
  color: #007bff;
}
.breadcrumb span:last-child {
  color: #333;
  cursor: default;
}
</style>
