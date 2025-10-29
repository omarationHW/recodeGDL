<template>
  <div class="consdesc-page">
    <h1>Consultas de Descuentos Prediales</h1>
    <div class="search-bar">
      <form @submit.prevent="onSearch">
        <div class="form-row">
          <label>Nombre Propietario:</label>
          <input v-model="search.propi" type="text" placeholder="Propietario" />
          <label>Folio Desc.:</label>
          <input v-model="search.foliodesc" type="text" placeholder="Folio" />
          <label>Recaudadora:</label>
          <input v-model="search.recaud" type="text" placeholder="Recaudadora" />
        </div>
        <div class="form-row">
          <label>Identificación:</label>
          <input v-model="search.identificacion" type="text" placeholder="Identificación" />
          <label>Solicitante:</label>
          <input v-model="search.solicitante" type="text" placeholder="Solicitante" />
          <label>Institución:</label>
          <select v-model="search.institucion">
            <option value="">Todas</option>
            <option v-for="inst in instituciones" :key="inst.cveinst" :value="inst.cveinst">{{ inst.institucion }}</option>
          </select>
        </div>
        <button type="submit">Buscar</button>
        <button type="button" @click="onClear">Limpiar</button>
      </form>
    </div>
    <div class="results-table">
      <table>
        <thead>
          <tr>
            <th>Folio</th>
            <th>Propietario</th>
            <th>Solicitante</th>
            <th>Identificación</th>
            <th>Institución</th>
            <th>Recaudadora</th>
            <th>Cuenta</th>
            <th>UR</th>
            <th>Descripción</th>
            <th>Observaciones</th>
            <th>Acciones</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in descuentos" :key="row.foliodesc">
            <td>{{ row.foliodesc }}</td>
            <td>{{ row.propie }}</td>
            <td>{{ row.solicitante }}</td>
            <td>{{ row.identificacion }}</td>
            <td>{{ getInstitucion(row.institucion) }}</td>
            <td>{{ row.recaud }}</td>
            <td>{{ row.cuenta }}</td>
            <td>{{ row.urbrus }}</td>
            <td>{{ row.descripcion }}</td>
            <td>{{ row.observaciones }}</td>
            <td>
              <button @click="verDetalle(row.foliodesc)">Ver Detalle</button>
            </td>
          </tr>
          <tr v-if="descuentos.length === 0">
            <td colspan="11">No hay resultados</td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-if="detalle" class="detalle-modal">
      <div class="detalle-content">
        <h2>Detalle de Descuento</h2>
        <button class="close" @click="detalle = null">Cerrar</button>
        <table>
          <tr><th>Folio</th><td>{{ detalle.foliodesc }}</td></tr>
          <tr><th>Propietario</th><td>{{ detalle.propie }}</td></tr>
          <tr><th>Solicitante</th><td>{{ detalle.solicitante }}</td></tr>
          <tr><th>Identificación</th><td>{{ detalle.identificacion }}</td></tr>
          <tr><th>Institución</th><td>{{ getInstitucion(detalle.institucion) }}</td></tr>
          <tr><th>Recaudadora</th><td>{{ detalle.recaud }}</td></tr>
          <tr><th>Cuenta</th><td>{{ detalle.cuenta }}</td></tr>
          <tr><th>UR</th><td>{{ detalle.urbrus }}</td></tr>
          <tr><th>Descripción</th><td>{{ detalle.descripcion }}</td></tr>
          <tr><th>Observaciones</th><td>{{ detalle.observaciones }}</td></tr>
          <tr><th>Fecha Alta</th><td>{{ detalle.fecalta }}</td></tr>
          <tr><th>Fecha Baja</th><td>{{ detalle.fecbaja }}</td></tr>
          <tr><th>Status</th><td>{{ detalle.status }}</td></tr>
        </table>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ConsDescPage',
  data() {
    return {
      search: {
        propi: '',
        foliodesc: '',
        recaud: '',
        identificacion: '',
        solicitante: '',
        institucion: ''
      },
      descuentos: [],
      instituciones: [],
      detalle: null
    };
  },
  created() {
    this.loadInstituciones();
    this.onSearch();
  },
  methods: {
    async onSearch() {
      const eRequest = {
        action: 'search',
        params: { ...this.search }
      };
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ eRequest })
      });
      const data = await res.json();
      if (data.eResponse.status === 'success') {
        this.descuentos = data.eResponse.data;
      } else {
        alert(data.eResponse.message);
      }
    },
    async loadInstituciones() {
      const eRequest = { action: 'instituciones' };
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ eRequest })
      });
      const data = await res.json();
      if (data.eResponse.status === 'success') {
        this.instituciones = data.eResponse.data;
      }
    },
    onClear() {
      this.search = {
        propi: '',
        foliodesc: '',
        recaud: '',
        identificacion: '',
        solicitante: '',
        institucion: ''
      };
      this.onSearch();
    },
    getInstitucion(id) {
      if (!id) return '';
      const inst = this.instituciones.find(i => i.cveinst == id);
      return inst ? inst.institucion : id;
    },
    async verDetalle(foliodesc) {
      const eRequest = { action: 'detalle', params: { id: foliodesc } };
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ eRequest })
      });
      const data = await res.json();
      if (data.eResponse.status === 'success') {
        this.detalle = data.eResponse.data;
      } else {
        alert(data.eResponse.message);
      }
    }
  }
};
</script>

<style scoped>
.consdesc-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
}
.search-bar {
  background: #f8f8f8;
  padding: 1rem;
  border-radius: 6px;
  margin-bottom: 1.5rem;
}
.form-row {
  display: flex;
  gap: 1rem;
  margin-bottom: 0.5rem;
  align-items: center;
}
.results-table table {
  width: 100%;
  border-collapse: collapse;
}
.results-table th, .results-table td {
  border: 1px solid #ddd;
  padding: 0.5rem;
  text-align: left;
}
.results-table th {
  background: #f0f0f0;
}
.detalle-modal {
  position: fixed;
  top: 0; left: 0; right: 0; bottom: 0;
  background: rgba(0,0,0,0.4);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}
.detalle-content {
  background: #fff;
  padding: 2rem;
  border-radius: 8px;
  min-width: 400px;
  max-width: 90vw;
  box-shadow: 0 2px 16px rgba(0,0,0,0.2);
  position: relative;
}
.detalle-content .close {
  position: absolute;
  top: 1rem;
  right: 1rem;
  background: #eee;
  border: none;
  border-radius: 50%;
  width: 2rem;
  height: 2rem;
  font-size: 1.2rem;
  cursor: pointer;
}
</style>
