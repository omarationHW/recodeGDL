<template>
  <div class="muestradup-page">
    <h1>Cuentas Duplicadas del Condominio</h1>
    <div class="breadcrumb">
      <router-link to="/">Inicio</router-link> /
      <span>Cuentas Duplicadas</span>
    </div>
    <div class="search-section">
      <label for="cvecond">Clave Catastral del Condominio:</label>
      <input v-model="cvecond" id="cvecond" maxlength="11" placeholder="Ej: D65J1123456" />
      <button @click="buscar">Buscar</button>
    </div>
    <div v-if="loading" class="loading">Cargando...</div>
    <div v-if="error" class="error">{{ error }}</div>
    <div v-if="duplicados.length > 0">
      <h2>Listado de Cuentas Duplicadas</h2>
      <table class="table table-bordered">
        <thead>
          <tr>
            <th>CveCond</th>
            <th>CveCuenta</th>
            <th>Recaud</th>
            <th>Urbrus</th>
            <th>Cuenta</th>
            <th>Subpredio</th>
            <th>Estado</th>
            <th>Acciones</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="dup in duplicados" :key="dup.cvecuenta">
            <td>{{ dup.cvecond }}</td>
            <td>{{ dup.cvecuenta }}</td>
            <td>{{ dup.recaud }}</td>
            <td>{{ dup.urbrus }}</td>
            <td>{{ dup.cuenta }}</td>
            <td>{{ dup.subpredio }}</td>
            <td>{{ estadoLabel(dup.estado) }}</td>
            <td>
              <button @click="verDetalle(dup)">Ver</button>
              <button v-if="dup.estado !== 'D'" @click="eliminar(dup)">Eliminar</button>
            </td>
          </tr>
        </tbody>
      </table>
      <div class="actions">
        <button @click="integrar" :disabled="integrando">Aplicar Integración</button>
      </div>
    </div>
    <div v-if="detalle">
      <h3>Detalle de Cuenta Duplicada</h3>
      <pre>{{ detalle }}</pre>
      <button @click="detalle = null">Cerrar</button>
    </div>
  </div>
</template>

<script>
export default {
  name: 'MuestraDupPage',
  data() {
    return {
      cvecond: '',
      duplicados: [],
      detalle: null,
      loading: false,
      error: '',
      integrando: false
    };
  },
  methods: {
    async buscar() {
      this.error = '';
      this.loading = true;
      this.duplicados = [];
      this.detalle = null;
      try {
        const resp = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: {
              action: 'list',
              params: { cvecond: this.cvecond }
            }
          })
        });
        const data = await resp.json();
        if (data.eResponse.success) {
          this.duplicados = data.eResponse.data;
        } else {
          this.error = data.eResponse.message;
        }
      } catch (e) {
        this.error = e.message;
      } finally {
        this.loading = false;
      }
    },
    async verDetalle(dup) {
      this.error = '';
      this.detalle = null;
      try {
        const resp = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: {
              action: 'show',
              params: { cvecuenta: dup.cvecuenta }
            }
          })
        });
        const data = await resp.json();
        if (data.eResponse.success) {
          this.detalle = data.eResponse.data;
        } else {
          this.error = data.eResponse.message;
        }
      } catch (e) {
        this.error = e.message;
      }
    },
    async eliminar(dup) {
      if (!confirm('¿Está seguro de eliminar la cuenta duplicada?')) return;
      this.error = '';
      try {
        const resp = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: {
              action: 'delete',
              params: { cvecuenta: dup.cvecuenta }
            }
          })
        });
        const data = await resp.json();
        if (data.eResponse.success) {
          this.buscar();
        } else {
          this.error = data.eResponse.message;
        }
      } catch (e) {
        this.error = e.message;
      }
    },
    async integrar() {
      if (!confirm('¿Está seguro de aplicar la integración de subpredios?')) return;
      this.integrando = true;
      this.error = '';
      try {
        const resp = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: {
              action: 'process',
              params: { cvecond: this.cvecond, usuario: 'web' }
            }
          })
        });
        const data = await resp.json();
        if (data.eResponse.success) {
          alert('Integración aplicada correctamente');
          this.buscar();
        } else {
          this.error = data.eResponse.message;
        }
      } catch (e) {
        this.error = e.message;
      } finally {
        this.integrando = false;
      }
    },
    estadoLabel(estado) {
      switch (estado) {
        case 'N': return 'Nuevo';
        case 'M': return 'Modificado';
        case 'R': return 'Reasignado';
        case 'D': return 'Eliminado';
        default: return estado;
      }
    }
  }
};
</script>

<style scoped>
.muestradup-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem;
}
.breadcrumb {
  margin-bottom: 1rem;
}
.search-section {
  margin-bottom: 2rem;
}
.loading {
  color: #888;
}
.error {
  color: red;
  margin: 1rem 0;
}
.table {
  width: 100%;
  border-collapse: collapse;
}
.table th, .table td {
  border: 1px solid #ccc;
  padding: 0.5rem;
}
.actions {
  margin-top: 1rem;
}
</style>
