<template>
  <div class="module-view">
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="store" /></div>
      <div class="module-view-info">
        <h1>Emisión de Recibos de Locales</h1>
        <p>Mercados - Emisión de Recibos de Locales</p>
      </div>
    </div>

    <div class="module-view-content">
    <h2>Emisión de Recibos de Locales</h2>
    <form @submit.prevent="onPreview">
      <div class="row mb-3">
        <div class="col-md-3">
          <label class="municipal-form-label">Oficina</label>
          <select v-model="form.oficina" class="municipal-form-control" @change="fetchMercados">
            <option value="">Seleccione...</option>
            <option v-for="of in oficinas" :key="of.id" :value="of.id">{{ of.nombre }}</option>
          </select>
        </div>
        <div class="col-md-3">
          <label class="municipal-form-label">Año</label>
          <input type="number" v-model.number="form.axo" class="municipal-form-control" min="1990" max="2100" required />
        </div>
        <div class="col-md-3">
          <label class="municipal-form-label">Mes</label>
          <select v-model.number="form.periodo" class="municipal-form-control" required>
            <option v-for="m in meses" :key="m.value" :value="m.value">{{ m.label }}</option>
          </select>
        </div>
        <div class="col-md-3">
          <label class="municipal-form-label">Mercado</label>
          <select v-model="form.mercado" class="municipal-form-control" required>
            <option value="">Seleccione...</option>
            <option v-for="m in mercados" :key="m.id" :value="m.id">{{ m.descripcion }}</option>
          </select>
        </div>
      </div>
      <div class="mb-3">
        <button type="submit" class="btn-municipal-primary">Previsualizar</button>
        <button type="button" class="btn btn-municipal-success ml-2" @click="onEmitir" :disabled="!previewData.length">Emitir Recibos</button>
      </div>
    </form>
    <div v-if="loading" class="alert alert-info">Cargando...</div>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>
    <div v-if="previewData.length">
      <h4>Previsualización de Recibos</h4>
      <table class="-bordered municipal-table-sm">
        <thead>
          <tr>
            <th>Local</th>
            <th>Nombre</th>
            <th>Descripción</th>
            <th>Superficie</th>
            <th>Renta</th>
            <th>Adeudo</th>
            <th>Recargos</th>
            <th>Subtotal</th>
            <th>Meses Adeudados</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in previewData" :key="row.id_local">
            <td>{{ row.local }}</td>
            <td>{{ row.nombre }}</td>
            <td>{{ row.descripcion_local }}</td>
            <td>{{ row.superficie }}</td>
            <td>{{ currency(row.renta) }}</td>
            <td>{{ currency(row.adeudo) }}</td>
            <td>{{ currency(row.recargos) }}</td>
            <td>{{ currency(row.subtotal) }}</td>
            <td>{{ row.meses }}</td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-if="successMsg" class="alert alert-success mt-3">{{ successMsg }}</div>
  </div>
    <!-- /module-view-content -->
  </div>
  <!-- /module-view -->
</template>

<script>
export default {
  name: 'RptEmisionLocalesPage',
  data() {
    return {
      form: {
        oficina: '',
        axo: new Date().getFullYear(),
        periodo: new Date().getMonth() + 1,
        mercado: ''
      },
      oficinas: [],
      mercados: [],
      meses: [
        { value: 1, label: 'Enero' }, { value: 2, label: 'Febrero' }, { value: 3, label: 'Marzo' },
        { value: 4, label: 'Abril' }, { value: 5, label: 'Mayo' }, { value: 6, label: 'Junio' },
        { value: 7, label: 'Julio' }, { value: 8, label: 'Agosto' }, { value: 9, label: 'Septiembre' },
        { value: 10, label: 'Octubre' }, { value: 11, label: 'Noviembre' }, { value: 12, label: 'Diciembre' }
      ],
      previewData: [],
      loading: false,
      error: '',
      successMsg: ''
    }
  },
  created() {
    this.fetchOficinas();
  },
  methods: {
    fetchOficinas() {
      // Simulación: en producción, llamar a /api/execute con action 'get-oficinas'
      this.oficinas = [
        { id: 1, nombre: 'Zona Centro' },
        { id: 2, nombre: 'Zona Olímpica' },
        { id: 3, nombre: 'Zona Oblatos' },
        { id: 4, nombre: 'Zona Minerva' },
        { id: 5, nombre: 'Zona Cruz del Sur' }
      ];
    },
    async fetchMercados() {
      if (!this.form.oficina) return;
      this.loading = true;
      this.error = '';
      try {
        const resp = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: {
              action: 'get-mercados',
              params: { oficina: this.form.oficina }
            }
          })
        });
        const data = await resp.json();
        this.mercados = data.eResponse.data.map(m => ({
          id: m.num_mercado_nvo,
          descripcion: m.descripcion
        }));
        this.loading = false;
      } catch (err) {
        this.error = 'Error al cargar mercados';
        this.loading = false;
      }
    },
    async onPreview() {
      this.loading = true;
      this.error = '';
      this.successMsg = '';
      try {
        const resp = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: {
              action: 'get',
              params: {
                oficina: this.form.oficina,
                axo: this.form.axo,
                periodo: this.form.periodo,
                mercado: this.form.mercado
              }
            }
          })
        });
        const data = await resp.json();
        if (data.eResponse.status === 'ok') {
          this.previewData = data.eResponse.data;
        } else {
          this.error = data.eResponse.message || 'Error en la consulta';
        }
        this.loading = false;
      } catch (err) {
        this.error = 'Error en la consulta';
        this.loading = false;
      }
    },
    async onEmitir() {
      if (!this.previewData.length) return;
      this.loading = true;
      this.error = '';
      this.successMsg = '';
      try {
        const resp = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: {
              action: 'emit',
              params: {
                oficina: this.form.oficina,
                axo: this.form.axo,
                periodo: this.form.periodo,
                mercado: this.form.mercado,
                usuario_id: this.$store?.state?.user?.id || 1 // Asumiendo autenticación
              }
            }
          })
        });
        const data = await resp.json();
        if (data.eResponse.status === 'ok') {
          this.successMsg = data.eResponse.message;
        } else {
          this.error = data.eResponse.message || 'Error al emitir';
        }
        this.loading = false;
      } catch (err) {
        this.error = 'Error al emitir';
        this.loading = false;
      }
    },
    currency(val) {
      if (val == null) return '';
      return '$' + Number(val).toLocaleString('es-MX', { minimumFractionDigits: 2 });
    }
  }
}
</script>

<style scoped>
.rpt-emision-locales-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem 1rem;
}
</style>
