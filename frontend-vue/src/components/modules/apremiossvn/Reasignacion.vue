<template>
  <div class="reasignacion-page">
    <h1>Reasignación de Ejecutor</h1>
    <div class="breadcrumb">
      <router-link to="/">Inicio</router-link> / Reasignación
    </div>
    <div class="form-section">
      <form @submit.prevent="buscarFolios">
        <div class="form-row">
          <label>Folio Desde</label>
          <input v-model.number="folioDesde" type="number" min="1" required />
          <label>Folio Hasta</label>
          <input v-model.number="folioHasta" type="number" min="1" required />
        </div>
        <div class="form-row">
          <label>Recaudadora</label>
          <select v-model="recaudadora" required>
            <option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">{{ rec.id_rec }} - {{ rec.recaudadora }}</option>
          </select>
        </div>
        <div class="form-row">
          <label>Aplicación</label>
          <select v-model="modulo" required>
            <option v-for="mod in modulos" :key="mod.value" :value="mod.value">{{ mod.label }}</option>
          </select>
        </div>
        <button type="submit">Buscar Folios</button>
      </form>
    </div>
    <div v-if="folios.length > 0" class="folios-section">
      <h2>Folios Encontrados</h2>
      <table class="folios-table">
        <thead>
          <tr>
            <th><input type="checkbox" @change="toggleAllFolios($event)" /></th>
            <th>Zona</th>
            <th>Folio</th>
            <th>Ejecutor</th>
            <th>Fecha Entrega 1</th>
            <th>Fecha Pago</th>
            <th>Importe Global</th>
            <th>Importe Multa</th>
            <th>Importe Recargo</th>
            <th>Importe Gastos</th>
            <th>Fecha Actualiz</th>
            <th>Usuario</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="folio in folios" :key="folio.id_control">
            <td><input type="checkbox" v-model="selectedFolios" :value="folio.id_control" /></td>
            <td>{{ folio.zona }}</td>
            <td>{{ folio.folio }}</td>
            <td>{{ folio.ejecutor }}</td>
            <td>{{ folio.fecha_entrega1 }}</td>
            <td>{{ folio.fecha_pago }}</td>
            <td>{{ folio.importe_global }}</td>
            <td>{{ folio.importe_multa }}</td>
            <td>{{ folio.importe_recargo }}</td>
            <td>{{ folio.importe_gastos }}</td>
            <td>{{ folio.fecha_actualiz }}</td>
            <td>{{ folio.usuario }}</td>
          </tr>
        </tbody>
      </table>
      <div class="reasignacion-form">
        <h3>Reasignar a Nuevo Ejecutor</h3>
        <label>Nuevo Ejecutor</label>
        <select v-model="nuevoEjecutor" required>
          <option v-for="eje in ejecutores" :key="eje.cve_eje" :value="eje.cve_eje">{{ eje.cve_eje }} - {{ eje.nombre }}</option>
        </select>
        <label>Fecha Entrega 2</label>
        <input type="date" v-model="fechaEntrega2" required />
        <button @click="reasignarFolios" :disabled="selectedFolios.length === 0">Reasignar Folios</button>
      </div>
    </div>
    <div v-if="mensaje" class="mensaje">
      {{ mensaje }}
    </div>
  </div>
</template>

<script>
export default {
  name: 'ReasignacionPage',
  data() {
    return {
      folioDesde: 1,
      folioHasta: 1,
      recaudadora: '',
      modulo: 16,
      modulos: [
        { value: 11, label: 'Mercados' },
        { value: 16, label: 'Aseo' },
        { value: 24, label: 'Estacionamientos Públicos' },
        { value: 28, label: 'Estacionamientos Exclusivos' },
        { value: 14, label: 'Estacionometros' },
        { value: 13, label: 'Cementerios' }
      ],
      recaudadoras: [],
      ejecutores: [],
      folios: [],
      selectedFolios: [],
      nuevoEjecutor: '',
      fechaEntrega2: '',
      mensaje: ''
    };
  },
  created() {
    this.cargarRecaudadoras();
    this.cargarEjecutores();
  },
  methods: {
    async cargarRecaudadoras() {
      // Llamada API para obtener recaudadoras
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          eRequest: { action: 'listar_recaudadoras' }
        })
      });
      const data = await res.json();
      this.recaudadoras = data.eResponse.data || [];
      if (this.recaudadoras.length > 0) {
        this.recaudadora = this.recaudadoras[0].id_rec;
      }
    },
    async cargarEjecutores() {
      // Llamada API para obtener ejecutores activos
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          eRequest: { action: 'listar_ejecutores', id_rec: 1, id_rec1: 9 }
        })
      });
      const data = await res.json();
      this.ejecutores = data.eResponse.data || [];
      if (this.ejecutores.length > 0) {
        this.nuevoEjecutor = this.ejecutores[0].cve_eje;
      }
    },
    async buscarFolios() {
      this.mensaje = '';
      if (this.folioDesde > this.folioHasta) {
        this.mensaje = 'Error: Folio Desde no puede ser mayor que Folio Hasta';
        return;
      }
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          eRequest: {
            action: 'buscar_folios',
            zona: this.recaudadora,
            modulo: this.modulo,
            folio1: this.folioDesde,
            folio2: this.folioHasta,
            vigencia: '1'
          }
        })
      });
      const data = await res.json();
      this.folios = data.eResponse.data || [];
      this.selectedFolios = [];
      if (this.folios.length === 0) {
        this.mensaje = 'No se encontraron folios para los criterios seleccionados.';
      }
    },
    toggleAllFolios(event) {
      if (event.target.checked) {
        this.selectedFolios = this.folios.map(f => f.id_control);
      } else {
        this.selectedFolios = [];
      }
    },
    async reasignarFolios() {
      if (!this.nuevoEjecutor || !this.fechaEntrega2) {
        this.mensaje = 'Debe seleccionar un ejecutor y una fecha de entrega.';
        return;
      }
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          eRequest: {
            action: 'reasignar_folios',
            folios: this.selectedFolios,
            nuevo_ejecutor: this.nuevoEjecutor,
            fecha_entrega2: this.fechaEntrega2,
            usuario: 1, // Debe obtenerse del contexto de sesión
            fecha_actualiz: new Date().toISOString().slice(0, 10)
          }
        })
      });
      const data = await res.json();
      if (data.eResponse.success) {
        this.mensaje = 'Folios reasignados correctamente.';
        this.buscarFolios();
      } else {
        this.mensaje = 'Error al reasignar folios: ' + data.eResponse.message;
      }
    }
  }
};
</script>

<style scoped>
.reasignacion-page {
  max-width: 1100px;
  margin: 0 auto;
  padding: 2rem;
}
.breadcrumb {
  margin-bottom: 1rem;
  font-size: 0.95rem;
}
.form-section {
  background: #f8f8f8;
  padding: 1rem;
  border-radius: 6px;
  margin-bottom: 2rem;
}
.form-row {
  display: flex;
  align-items: center;
  gap: 1rem;
  margin-bottom: 1rem;
}
.folios-section {
  margin-top: 2rem;
}
.folios-table {
  width: 100%;
  border-collapse: collapse;
  margin-bottom: 1rem;
}
.folios-table th, .folios-table td {
  border: 1px solid #ccc;
  padding: 0.4rem 0.6rem;
  text-align: left;
}
.reasignacion-form {
  margin-top: 1.5rem;
  background: #f0f0f0;
  padding: 1rem;
  border-radius: 6px;
  max-width: 400px;
}
.mensaje {
  margin-top: 1.5rem;
  color: #b00;
  font-weight: bold;
}
</style>
