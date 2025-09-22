<template>
  <div class="cons-pagos-locales-page">
    <h1>Consulta de Pagos del Local</h1>
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Pagos Locales</li>
      </ol>
    </nav>
    <div class="card mb-3">
      <div class="card-body">
        <div class="row mb-2">
          <div class="col-md-2">
            <label><input type="radio" v-model="opcion" value="L" @change="onOpcionChange"> Por Local</label>
          </div>
          <div class="col-md-2">
            <label><input type="radio" v-model="opcion" value="F" @change="onOpcionChange"> Por Fecha de Pago</label>
          </div>
        </div>
        <div v-if="opcion==='L'">
          <div class="row mb-2">
            <div class="col-md-2">
              <label>Recaudadora</label>
              <select v-model="form.oficina" class="form-control" @change="onOficinaChange">
                <option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">{{ rec.id_rec }}</option>
              </select>
            </div>
            <div class="col-md-2">
              <label>Mercado</label>
              <select v-model="form.num_mercado" class="form-control" @change="onMercadoChange">
                <option v-for="merc in mercados" :key="merc.num_mercado_nvo" :value="merc.num_mercado_nvo">{{ merc.num_mercado_nvo }} - {{ merc.descripcion }}</option>
              </select>
            </div>
            <div class="col-md-1">
              <label>Cat.</label>
              <input v-model="form.categoria" class="form-control" maxlength="1" />
            </div>
            <div class="col-md-2">
              <label>Sección</label>
              <select v-model="form.seccion" class="form-control">
                <option v-for="sec in secciones" :key="sec.seccion" :value="sec.seccion">{{ sec.seccion }}</option>
              </select>
            </div>
            <div class="col-md-2">
              <label>Local</label>
              <input v-model="form.local" class="form-control" />
            </div>
            <div class="col-md-1">
              <label>Letra</label>
              <input v-model="form.letra_local" class="form-control" maxlength="1" />
            </div>
            <div class="col-md-1">
              <label>Bloque</label>
              <input v-model="form.bloque" class="form-control" maxlength="1" />
            </div>
          </div>
        </div>
        <div v-if="opcion==='F'">
          <div class="row mb-2">
            <div class="col-md-3">
              <label>Fecha de Pago</label>
              <input type="date" v-model="form.fecha_pago" class="form-control" />
            </div>
            <div class="col-md-2">
              <label>Oficina</label>
              <select v-model="form.oficina_pago" class="form-control" @change="onOficinaPagoChange">
                <option v-for="rec in recaudadoras" :key="rec.id_rec" :value="rec.id_rec">{{ rec.id_rec }}</option>
              </select>
            </div>
            <div class="col-md-2">
              <label>Caja</label>
              <select v-model="form.caja_pago" class="form-control">
                <option v-for="caja in cajas" :key="caja.caja" :value="caja.caja">{{ caja.caja }}</option>
              </select>
            </div>
            <div class="col-md-2">
              <label>Operación</label>
              <input v-model="form.operacion_pago" class="form-control" />
            </div>
          </div>
        </div>
        <div class="row mt-3">
          <div class="col-md-2">
            <button class="btn btn-primary" @click="buscarPagos">Buscar</button>
          </div>
          <div class="col-md-2">
            <button class="btn btn-secondary" @click="resetForm">Limpiar</button>
          </div>
        </div>
      </div>
    </div>
    <div v-if="pagos.length > 0" class="card">
      <div class="card-body">
        <h5>Resultados</h5>
        <div class="table-responsive">
          <table class="table table-bordered table-sm">
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
                <th>Rec. Pago</th>
                <th>Caja</th>
                <th>Operación</th>
                <th>Renta</th>
                <th>Partida</th>
                <th>Actualización</th>
                <th>Usuario</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="row in pagos" :key="row.id_pago_local">
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
                <td>{{ row.fecha_modificacion_1 }}</td>
                <td>{{ row.usuario }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
    <div v-if="loading" class="text-center my-3">
      <span class="spinner-border"></span> Cargando...
    </div>
    <div v-if="error" class="alert alert-danger mt-3">{{ error }}</div>
  </div>
</template>

<script>
export default {
  name: 'ConsPagosLocalesPage',
  data() {
    return {
      opcion: '',
      form: {
        oficina: '',
        num_mercado: '',
        categoria: '',
        seccion: '',
        local: '',
        letra_local: '',
        bloque: '',
        fecha_pago: '',
        oficina_pago: '',
        caja_pago: '',
        operacion_pago: ''
      },
      recaudadoras: [],
      mercados: [],
      secciones: [],
      cajas: [],
      pagos: [],
      loading: false,
      error: ''
    }
  },
  mounted() {
    this.fetchRecaudadoras();
    this.fetchSecciones();
  },
  methods: {
    async fetchRecaudadoras() {
      this.loading = true;
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'getRecaudadoras' })
      });
      const data = await res.json();
      this.recaudadoras = data.data || [];
      this.loading = false;
    },
    async fetchSecciones() {
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'getSecciones' })
      });
      const data = await res.json();
      this.secciones = data.data || [];
    },
    async onOficinaChange() {
      this.form.num_mercado = '';
      this.form.categoria = '';
      this.mercados = [];
      if (!this.form.oficina) return;
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'getMercadosByOficina', params: { oficina: this.form.oficina } })
      });
      const data = await res.json();
      this.mercados = data.data || [];
    },
    async onMercadoChange() {
      const selected = this.mercados.find(m => m.num_mercado_nvo == this.form.num_mercado);
      if (selected) {
        this.form.categoria = selected.categoria;
      }
    },
    async onOficinaPagoChange() {
      this.cajas = [];
      if (!this.form.oficina_pago) return;
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'getCajasByOficina', params: { oficina: this.form.oficina_pago } })
      });
      const data = await res.json();
      this.cajas = data.data || [];
    },
    onOpcionChange() {
      this.pagos = [];
      this.error = '';
      this.resetForm();
    },
    async buscarPagos() {
      this.loading = true;
      this.error = '';
      let action = '';
      let params = {};
      if (this.opcion === 'L') {
        action = 'buscarPagosPorLocal';
        params = {
          oficina: this.form.oficina,
          num_mercado: this.form.num_mercado,
          categoria: this.form.categoria,
          seccion: this.form.seccion,
          local: this.form.local,
          letra_local: this.form.letra_local,
          bloque: this.form.bloque
        };
      } else if (this.opcion === 'F') {
        action = 'buscarPagosPorFecha';
        params = {
          fecha_pago: this.form.fecha_pago,
          oficina_pago: this.form.oficina_pago,
          caja_pago: this.form.caja_pago,
          operacion_pago: this.form.operacion_pago
        };
      } else {
        this.error = 'Seleccione una opción de búsqueda.';
        this.loading = false;
        return;
      }
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ action, params })
        });
        const data = await res.json();
        if (data.success) {
          this.pagos = data.data;
        } else {
          this.error = data.message || 'Error en la consulta.';
        }
      } catch (e) {
        this.error = 'Error de red o servidor.';
      }
      this.loading = false;
    },
    resetForm() {
      this.form = {
        oficina: '',
        num_mercado: '',
        categoria: '',
        seccion: '',
        local: '',
        letra_local: '',
        bloque: '',
        fecha_pago: '',
        oficina_pago: '',
        caja_pago: '',
        operacion_pago: ''
      };
      this.pagos = [];
      this.cajas = [];
      this.mercados = [];
    }
  }
}
</script>

<style scoped>
.cons-pagos-locales-page {
  max-width: 1200px;
  margin: 0 auto;
}
.card {
  margin-bottom: 1rem;
}
.table th, .table td {
  font-size: 0.95rem;
}
</style>
