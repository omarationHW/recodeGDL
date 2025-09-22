<template>
  <div class="consulta-licencia-page">
    <h1>Consulta de Licencias</h1>
    <nav class="breadcrumb">
      <span>Inicio</span> &gt; <span>Licencias</span> &gt; <span>Consulta</span>
    </nav>
    <section class="search-section">
      <h2>Búsqueda</h2>
      <form @submit.prevent="buscar">
        <div class="form-row">
          <label>No. Licencia:</label>
          <input v-model="form.licencia" type="text" />
          <button type="button" @click="buscarPor('licencia')">Buscar</button>
        </div>
        <div class="form-row">
          <label>Ubicación:</label>
          <input v-model="form.ubicacion" type="text" />
          <button type="button" @click="buscarPor('ubicacion')">Buscar</button>
        </div>
        <div class="form-row">
          <label>Contribuyente:</label>
          <input v-model="form.propietario" type="text" />
          <button type="button" @click="buscarPor('contribuyente')">Buscar</button>
        </div>
        <div class="form-row">
          <label>No. Trámite:</label>
          <input v-model="form.id_tramite" type="text" />
          <button type="button" @click="buscarPor('tramite')">Buscar</button>
        </div>
      </form>
    </section>
    <section class="result-section" v-if="resultados.length">
      <h2>Resultados</h2>
      <table class="result-table">
        <thead>
          <tr>
            <th>Licencia</th>
            <th>Propietario</th>
            <th>Ubicación</th>
            <th>Actividad</th>
            <th>Vigencia</th>
            <th>Bloqueado</th>
            <th>Acciones</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="lic in resultados" :key="lic.id_licencia">
            <td>{{ lic.licencia }}</td>
            <td>{{ lic.propietario }}</td>
            <td>{{ lic.ubicacion }}</td>
            <td>{{ lic.actividad }}</td>
            <td>{{ lic.vigente }}</td>
            <td>{{ lic.bloqueado ? 'Sí' : 'No' }}</td>
            <td>
              <button @click="verDetalle(lic)">Detalle</button>
              <button v-if="!lic.bloqueado" @click="bloquear(lic)">Bloquear</button>
              <button v-if="lic.bloqueado" @click="desbloquear(lic)">Desbloquear</button>
              <button @click="verPagos(lic)">Pagos</button>
              <button @click="verAdeudos(lic)">Adeudos</button>
            </td>
          </tr>
        </tbody>
      </table>
      <div class="export-section">
        <button @click="exportarExcel">Exportar a Excel</button>
      </div>
    </section>
    <section v-if="detalle">
      <h2>Detalle de Licencia</h2>
      <div class="detalle-grid">
        <div><strong>Licencia:</strong> {{ detalle.licencia }}</div>
        <div><strong>Propietario:</strong> {{ detalle.propietario }}</div>
        <div><strong>Ubicación:</strong> {{ detalle.ubicacion }}</div>
        <div><strong>Actividad:</strong> {{ detalle.actividad }}</div>
        <div><strong>Vigencia:</strong> {{ detalle.vigente }}</div>
        <div><strong>Bloqueado:</strong> {{ detalle.bloqueado ? 'Sí' : 'No' }}</div>
        <div><strong>Correo:</strong> {{ detalle.email }}</div>
        <div><strong>Teléfono:</strong> {{ detalle.telefono_prop }}</div>
        <div><strong>Zona:</strong> {{ detalle.zona }}</div>
        <div><strong>Subzona:</strong> {{ detalle.subzona }}</div>
        <div><strong>Fecha de Otorgamiento:</strong> {{ detalle.fecha_otorgamiento }}</div>
        <div><strong>Fecha de Baja:</strong> {{ detalle.fecha_baja }}</div>
      </div>
      <button @click="detalle = null">Cerrar</button>
    </section>
    <section v-if="pagos.length">
      <h2>Pagos</h2>
      <table class="result-table">
        <thead>
          <tr>
            <th>Fecha</th>
            <th>Importe</th>
            <th>Cajero</th>
            <th>Folio</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="p in pagos" :key="p.cvepago">
            <td>{{ p.fecha }}</td>
            <td>{{ p.importe }}</td>
            <td>{{ p.cajero }}</td>
            <td>{{ p.folio }}</td>
          </tr>
        </tbody>
      </table>
      <button @click="pagos = []">Cerrar</button>
    </section>
    <section v-if="adeudos.length">
      <h2>Adeudos</h2>
      <table class="result-table">
        <thead>
          <tr>
            <th>Año</th>
            <th>Derechos</th>
            <th>Recargos</th>
            <th>Formas</th>
            <th>Saldo</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="a in adeudos" :key="a.axo">
            <td>{{ a.axo }}</td>
            <td>{{ a.derechos }}</td>
            <td>{{ a.recargos }}</td>
            <td>{{ a.formas }}</td>
            <td>{{ a.saldo }}</td>
          </tr>
        </tbody>
      </table>
      <button @click="adeudos = []">Cerrar</button>
    </section>
    <div v-if="loading" class="loading">Cargando...</div>
    <div v-if="error" class="error">{{ error }}</div>
  </div>
</template>

<script>
export default {
  name: 'ConsultaLicenciaPage',
  data() {
    return {
      form: {
        licencia: '',
        ubicacion: '',
        propietario: '',
        id_tramite: ''
      },
      resultados: [],
      detalle: null,
      pagos: [],
      adeudos: [],
      loading: false,
      error: ''
    };
  },
  methods: {
    async buscarPor(tipo) {
      this.loading = true;
      this.error = '';
      let operation = '';
      let params = {};
      if (tipo === 'licencia') {
        operation = 'search_by_licencia';
        params = { licencia: this.form.licencia };
      } else if (tipo === 'ubicacion') {
        operation = 'search_by_ubicacion';
        params = { ubicacion: this.form.ubicacion };
      } else if (tipo === 'contribuyente') {
        operation = 'search_by_contribuyente';
        params = { propietario: this.form.propietario };
      } else if (tipo === 'tramite') {
        operation = 'search_by_tramite';
        params = { id_tramite: this.form.id_tramite };
      }
      try {
        const res = await this.$axios.post('/api/execute', {
          eRequest: { operation, params }
        });
        if (res.data.eResponse.error) {
          this.error = res.data.eResponse.error;
          this.resultados = [];
        } else {
          this.resultados = res.data.eResponse.result;
        }
      } catch (e) {
        this.error = e.message;
      } finally {
        this.loading = false;
      }
    },
    buscar() {
      // Por defecto busca por licencia
      this.buscarPor('licencia');
    },
    verDetalle(lic) {
      this.detalle = lic;
    },
    async verPagos(lic) {
      this.loading = true;
      this.error = '';
      try {
        const res = await this.$axios.post('/api/execute', {
          eRequest: { operation: 'get_pagos', params: { id_licencia: lic.id_licencia } }
        });
        if (res.data.eResponse.error) {
          this.error = res.data.eResponse.error;
          this.pagos = [];
        } else {
          this.pagos = res.data.eResponse.result;
        }
      } catch (e) {
        this.error = e.message;
      } finally {
        this.loading = false;
      }
    },
    async verAdeudos(lic) {
      this.loading = true;
      this.error = '';
      try {
        const res = await this.$axios.post('/api/execute', {
          eRequest: { operation: 'get_adeudos', params: { id_licencia: lic.id_licencia, tipo: 'L' } }
        });
        if (res.data.eResponse.error) {
          this.error = res.data.eResponse.error;
          this.adeudos = [];
        } else {
          this.adeudos = res.data.eResponse.result;
        }
      } catch (e) {
        this.error = e.message;
      } finally {
        this.loading = false;
      }
    },
    async bloquear(lic) {
      const motivo = prompt('Motivo del bloqueo:');
      if (!motivo) return;
      this.loading = true;
      this.error = '';
      try {
        const res = await this.$axios.post('/api/execute', {
          eRequest: { operation: 'bloquear_licencia', params: { id_licencia: lic.id_licencia, tipo_bloqueo: 1, motivo } }
        });
        if (res.data.eResponse.error) {
          this.error = res.data.eResponse.error;
        } else {
          alert('Licencia bloqueada');
          this.buscar();
        }
      } catch (e) {
        this.error = e.message;
      } finally {
        this.loading = false;
      }
    },
    async desbloquear(lic) {
      const motivo = prompt('Motivo del desbloqueo:');
      if (!motivo) return;
      this.loading = true;
      this.error = '';
      try {
        const res = await this.$axios.post('/api/execute', {
          eRequest: { operation: 'desbloquear_licencia', params: { id_licencia: lic.id_licencia, tipo_bloqueo: 1, motivo } }
        });
        if (res.data.eResponse.error) {
          this.error = res.data.eResponse.error;
        } else {
          alert('Licencia desbloqueada');
          this.buscar();
        }
      } catch (e) {
        this.error = e.message;
      } finally {
        this.loading = false;
      }
    },
    async exportarExcel() {
      this.loading = true;
      this.error = '';
      try {
        const res = await this.$axios.post('/api/execute', {
          eRequest: { operation: 'exportar_excel', params: { filtros: this.form } }
        });
        if (res.data.eResponse.error) {
          this.error = res.data.eResponse.error;
        } else {
          // Suponiendo que el backend regresa una URL de descarga
          window.open(res.data.eResponse.result.url, '_blank');
        }
      } catch (e) {
        this.error = e.message;
      } finally {
        this.loading = false;
      }
    }
  }
};
</script>

<style scoped>
.consulta-licencia-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
}
.breadcrumb {
  margin-bottom: 1rem;
  color: #888;
}
.search-section {
  background: #f8f8f8;
  padding: 1rem;
  border-radius: 4px;
  margin-bottom: 2rem;
}
.form-row {
  display: flex;
  align-items: center;
  margin-bottom: 0.5rem;
}
.form-row label {
  width: 140px;
  font-weight: bold;
}
.form-row input {
  flex: 1;
  margin-right: 1rem;
}
.result-section {
  margin-bottom: 2rem;
}
.result-table {
  width: 100%;
  border-collapse: collapse;
  margin-bottom: 1rem;
}
.result-table th, .result-table td {
  border: 1px solid #ddd;
  padding: 0.5rem;
}
.result-table th {
  background: #eee;
}
.detalle-grid {
  display: grid;
  grid-template-columns: 1fr 1fr 1fr;
  gap: 1rem;
  margin-bottom: 1rem;
}
.loading {
  color: #007bff;
  font-weight: bold;
}
.error {
  color: #c00;
  font-weight: bold;
}
.export-section {
  margin-top: 1rem;
}
</style>
