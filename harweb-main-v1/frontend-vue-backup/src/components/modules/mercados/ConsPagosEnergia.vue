<template>
  <div class="cons-pagos-energia-page">
    <h1>Consulta de Pagos de Energía</h1>
    <nav class="breadcrumb">
      <span>Inicio</span> &gt; <span>Consultas</span> &gt; <span>Pagos de Energía</span>
    </nav>
    <div class="card">
      <div class="card-header">
        <strong>Clasificación</strong>
      </div>
      <div class="card-body">
        <div class="form-group">
          <label><input type="radio" v-model="searchType" value="local" /> Por Local</label>
          <label><input type="radio" v-model="searchType" value="fecha_pago" /> Por Fecha de Pago</label>
        </div>
        <div v-if="searchType==='local'">
          <div class="row">
            <div class="col">
              <label>Recaudadora</label>
              <select v-model="formLocal.oficina" @change="onRecaudadoraChange">
                <option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">{{ rec.recaudadora }}</option>
              </select>
            </div>
            <div class="col">
              <label>Mercado</label>
              <input v-model="formLocal.num_mercado" maxlength="3" />
            </div>
            <div class="col">
              <label>Categoria</label>
              <input v-model="formLocal.categoria" maxlength="1" />
            </div>
            <div class="col">
              <label>Sección</label>
              <select v-model="formLocal.seccion">
                <option v-for="sec in secciones" :key="sec.seccion" :value="sec.seccion">{{ sec.descripcion }}</option>
              </select>
            </div>
            <div class="col">
              <label>Local</label>
              <input v-model="formLocal.local" maxlength="5" />
            </div>
            <div class="col">
              <label>Letra</label>
              <input v-model="formLocal.letra_local" maxlength="1" />
            </div>
            <div class="col">
              <label>Bloque</label>
              <input v-model="formLocal.bloque" maxlength="1" />
            </div>
          </div>
        </div>
        <div v-if="searchType==='fecha_pago'">
          <div class="row">
            <div class="col">
              <label>Fecha de Pago</label>
              <input type="date" v-model="formFechaPago.fecha_pago" />
            </div>
            <div class="col">
              <label>Oficina</label>
              <select v-model="formFechaPago.oficina_pago" @change="onOficinaPagoChange">
                <option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">{{ rec.recaudadora }}</option>
              </select>
            </div>
            <div class="col">
              <label>Caja</label>
              <select v-model="formFechaPago.caja_pago">
                <option v-for="caja in cajas" :key="caja.caja" :value="caja.caja">{{ caja.caja }}</option>
              </select>
            </div>
            <div class="col">
              <label>Operación</label>
              <input v-model="formFechaPago.operacion_pago" maxlength="5" />
            </div>
          </div>
        </div>
        <div class="form-group mt-2">
          <button @click="buscar" class="btn btn-primary">Buscar</button>
          <button @click="limpiar" class="btn btn-secondary">Limpiar</button>
        </div>
      </div>
    </div>
    <div class="card mt-3" v-if="resultados.length">
      <div class="card-header">
        <strong>Resultados</strong>
      </div>
      <div class="card-body">
        <table class="table table-sm table-bordered table-striped">
          <thead>
            <tr>
              <th>Control</th>
              <th>Rec.</th>
              <th>Mercado</th>
              <th>Cat.</th>
              <th>Sec.</th>
              <th>Local</th>
              <th>Letra</th>
              <th>Bloque</th>
              <th>Año</th>
              <th>Mes</th>
              <th>Fecha Pago</th>
              <th>Oficina Pago</th>
              <th>Caja</th>
              <th>Operación</th>
              <th>Importe</th>
              <th>Folio</th>
              <th>Usuario</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="row in resultados" :key="row.id_pago_energia">
              <td>{{ row.id_local }}</td>
              <td>{{ row.oficina }}</td>
              <td>{{ row.num_mercado }}</td>
              <td>{{ row.categoria }}</td>
              <td>{{ row.seccion }}</td>
              <td>{{ row.local }}</td>
              <td>{{ row.letra_local }}</td>
              <td>{{ row.bloque }}</td>
              <td>{{ row.axo }}</td>
              <td>{{ row.periodo }}</td>
              <td>{{ row.fecha_pago }}</td>
              <td>{{ row.oficina_pago }}</td>
              <td>{{ row.caja_pago }}</td>
              <td>{{ row.operacion_pago }}</td>
              <td>{{ row.importe_pago }}</td>
              <td>{{ row.folio }}</td>
              <td>{{ row.usuario }}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ConsPagosEnergiaPage',
  data() {
    return {
      searchType: 'local',
      recaudadoras: [],
      secciones: [],
      cajas: [],
      resultados: [],
      formLocal: {
        oficina: '',
        num_mercado: '',
        categoria: '',
        seccion: '',
        local: '',
        letra_local: '',
        bloque: ''
      },
      formFechaPago: {
        fecha_pago: '',
        oficina_pago: '',
        caja_pago: '',
        operacion_pago: ''
      }
    }
  },
  mounted() {
    this.loadRecaudadoras();
    this.loadSecciones();
  },
  methods: {
    async loadRecaudadoras() {
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ eRequest: { action: 'getRecaudadoras' } })
      });
      const data = await res.json();
      this.recaudadoras = data.eResponse.data;
    },
    async loadSecciones() {
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ eRequest: { action: 'getSecciones' } })
      });
      const data = await res.json();
      this.secciones = data.eResponse.data;
    },
    async onRecaudadoraChange() {
      // Opcional: cargar mercados si se requiere
    },
    async onOficinaPagoChange() {
      if (!this.formFechaPago.oficina_pago) return;
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ eRequest: { action: 'getCajasByOficina', params: { oficina: this.formFechaPago.oficina_pago } } })
      });
      const data = await res.json();
      this.cajas = data.eResponse.data;
    },
    async buscar() {
      let action = '';
      let params = {};
      if (this.searchType === 'local') {
        action = 'searchByLocal';
        params = { ...this.formLocal, orden: 'axo,periodo' };
      } else {
        action = 'searchByFechaPago';
        params = { ...this.formFechaPago, orden: 'fecha_pago,oficina_pago,caja_pago,operacion_pago' };
      }
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ eRequest: { action, params } })
      });
      const data = await res.json();
      this.resultados = data.eResponse.data || [];
    },
    limpiar() {
      this.resultados = [];
      this.formLocal = { oficina: '', num_mercado: '', categoria: '', seccion: '', local: '', letra_local: '', bloque: '' };
      this.formFechaPago = { fecha_pago: '', oficina_pago: '', caja_pago: '', operacion_pago: '' };
    }
  }
}
</script>

<style scoped>
.cons-pagos-energia-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 1rem;
}
.card {
  border: 1px solid #ccc;
  border-radius: 4px;
  margin-bottom: 1rem;
}
.card-header {
  background: #f7f7f7;
  padding: 0.5rem 1rem;
  font-weight: bold;
}
.card-body {
  padding: 1rem;
}
.row {
  display: flex;
  flex-wrap: wrap;
  gap: 1rem;
}
.col {
  flex: 1 1 120px;
  min-width: 120px;
}
.table {
  width: 100%;
  font-size: 0.95rem;
}
.breadcrumb {
  font-size: 0.9rem;
  margin-bottom: 1rem;
  color: #888;
}
</style>
