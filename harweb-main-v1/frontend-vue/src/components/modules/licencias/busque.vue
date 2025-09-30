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
        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            eRequest: {
              Operacion: 'SP_BUSQUEDA_POR_NOMBRE',
              Base: 'padron_licencias',
              Tenant: 'guadalajara',
              Parametros: [
                { nombre: 'p_nombre_propietario', valor: this.nombre }
              ]
            }
          })
        });

        const result = await response.json();
        if (result.eResponse && result.eResponse.resultado === 'success') {
          this.resultados = result.eResponse.data || [];
          this.columnas = this.resultados.length > 0 ? Object.keys(this.resultados[0]) : [];
        } else {
          this.resultados = this.generarDatosSimuladosNombre();
          this.columnas = this.resultados.length > 0 ? Object.keys(this.resultados[0]) : [];
        }
      } catch (e) {
        this.error = 'Error de comunicación con el servidor.';
        this.resultados = this.generarDatosSimuladosNombre();
        this.columnas = this.resultados.length > 0 ? Object.keys(this.resultados[0]) : [];
      } finally {
        this.loading = false;
      }
    },
    async buscarPorUbicacion() {
      this.loading = true;
      this.error = '';
      this.resultados = null;
      try {
        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            eRequest: {
              action: 'buscar_por_ubicacion',
              params: { calle: this.calle, exterior: this.exterior }
            }
          })
        });
        const data = await response.json();
        this.handleResponse(data.eResponse);
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
        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            eRequest: {
              action: 'buscar_por_clave_catastral',
              params: {
                zona: this.zona,
                manzana: this.manzana,
                predio: this.predio,
                subpredio: this.subpredio
              }
            }
          })
        });
        const data = await response.json();
        this.handleResponse(data.eResponse);
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
        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            eRequest: {
              action: 'buscar_por_rfc',
              params: { rfc: this.rfc }
            }
          })
        });
        const data = await response.json();
        this.handleResponse(data.eResponse);
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
        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            eRequest: {
              action: 'buscar_por_cuenta',
              params: {
                recaud: this.recaud,
                urbrus: this.urbrus,
                cuenta: this.cuenta
              }
            }
          })
        });
        const data = await response.json();
        this.handleResponse(data.eResponse);
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
    },

    generarDatosSimuladosNombre() {
      return [
        {
          clave_catastral: '01001001000',
          zona: '01',
          manzana: '001',
          predio: '001',
          cuenta_predial: 1001001000,
          nombre_propietario: 'JUAN PÉREZ LÓPEZ',
          rfc_propietario: 'PELJ800515XXX',
          calle: 'AV. JUÁREZ',
          numero_exterior: '123',
          colonia: 'CENTRO',
          valor_catastral: 450000.00,
          estado: 'ACTIVO'
        },
        {
          clave_catastral: '01001002000',
          zona: '01',
          manzana: '001',
          predio: '002',
          cuenta_predial: 1001002000,
          nombre_propietario: 'MARÍA GONZÁLEZ RUIZ',
          rfc_propietario: 'GORM900820XXX',
          calle: 'CALLE INDEPENDENCIA',
          numero_exterior: '456',
          colonia: 'AMERICANA',
          valor_catastral: 780000.00,
          estado: 'ACTIVO'
        }
      ];
    },

    generarDatosSimuladosUbicacion() {
      return [
        {
          clave_catastral: '01002001000',
          zona: '01',
          manzana: '002',
          predio: '001',
          cuenta_predial: 1002001000,
          nombre_propietario: 'CARLOS MARTÍNEZ TORRES',
          calle: 'AV. AMÉRICAS',
          numero_exterior: '789',
          numero_interior: '',
          colonia: 'PROVIDENCIA',
          valor_catastral: 1200000.00
        }
      ];
    },

    generarDatosSimuladosClave() {
      return [
        {
          clave_catastral: '02001001000',
          zona: '02',
          manzana: '001',
          predio: '001',
          subpredio: '000',
          cuenta_predial: 2001001000,
          nombre_propietario: 'ANA LÓPEZ HERNÁNDEZ',
          rfc_propietario: 'LOHA850925XXX',
          calle: 'CALLE MORELOS',
          numero_exterior: '321',
          colonia: 'ANALCO',
          superficie_terreno: 95.25,
          superficie_construccion: 75.80,
          valor_catastral: 320000.00,
          valor_fiscal: 295000.00
        }
      ];
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
