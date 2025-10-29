<template>
  <div class="module-view">
    <h1>Emisión de Recibos de Locales</h1>
    <div class="module-view-header">
      <div class="module-view-icon"><font-awesome-icon icon="store" /></div>
      <div class="module-view-info">
        <h1>Emisión de Recibos</h1>
        <p>Mercados - Emisión de Recibos</p>
      </div>
    </div>

    <div class="module-view-content">
    <form @submit.prevent="emitirRecibos">
      <div class="form-row">
        <div class="form-group col-md-3">
          <label>Recaudadora</label>
          <select v-model="form.oficina" class="municipal-form-control" required @change="listarMercados">
            <option v-for="rec in recaudadoras" :key="rec.id" :value="rec.id">{{ rec.nombre }}</option>
          </select>
        </div>
        <div class="form-group col-md-3">
          <label>Mercado</label>
          <select v-model="form.mercado" class="municipal-form-control" required>
            <option v-for="merc in mercados" :key="merc.num_mercado_nvo" :value="merc.num_mercado_nvo">{{ merc.descripcion }}</option>
          </select>
        </div>
        <div class="form-group col-md-2">
          <label>Año</label>
          <input type="number" v-model.number="form.axo" class="municipal-form-control" min="2003" max="2999" required />
        </div>
        <div class="form-group col-md-2">
          <label>Periodo (Mes)</label>
          <input type="number" v-model.number="form.periodo" class="municipal-form-control" min="1" max="12" required />
        </div>
      </div>
      <div class="form-row mt-2">
        <button type="submit" class="btn btn-primary mr-2">Emisión</button>
        <button type="button" class="btn btn-success mr-2" @click="grabarEmision">Grabar</button>
        <button type="button" class="btn btn-info mr-2" @click="facturacion">Facturación</button>
      </div>
    </form>
    <div v-if="recibos.length" class="mt-4">
      <h3>Recibos Generados</h3>
      <table class="municipal-table">
        <thead>
          <tr>
            <th>Local</th>
            <th>Nombre</th>
            <th>Descripción</th>
            <th>Superficie</th>
            <th>Renta</th>
            <th>Subtotal</th>
            <th>Meses</th>
            <th>Acciones</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="rec in recibos" :key="rec.id_local">
            <td>{{ rec.local }}</td>
            <td>{{ rec.nombre }}</td>
            <td>{{ rec.descripcion_local }}</td>
            <td>{{ rec.superficie }}</td>
            <td>{{ rec.renta | currency }}</td>
            <td>{{ rec.subtotal | currency }}</td>
            <td>{{ rec.meses }}</td>
            <td>
              <button class="btn btn-link btn-sm" @click="verDetalle(rec.id_local)">Detalle</button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-if="detalleLocal" class="modal fade show d-block" tabindex="-1" role="dialog">
      <div class="modal-dialog modal-lg" role="document">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">Detalle del Local</h5>
            <button type="button" class="close" @click="detalleLocal = null"><span>&times;</span></button>
          </div>
          <div class="modal-body">
            <pre>{{ detalleLocal }}</pre>
          </div>
        </div>
      </div>
    </div>
    <div v-if="error" class="alert alert-danger mt-3">{{ error }}</div>
    <div v-if="success" class="alert alert-success mt-3">{{ success }}</div>
  </div>
    <!-- /module-view-content -->
  </div>
  <!-- /module-view -->
</template>

<script>
export default {
  name: 'EmisionLocalesPage',
  data() {
    return {
      recaudadoras: [],
      mercados: [],
      recibos: [],
      detalleLocal: null,
      error: '',
      success: '',
      form: {
        oficina: '',
        mercado: '',
        axo: new Date().getFullYear(),
        periodo: new Date().getMonth() + 1
      }
    };
  },
  filters: {
    currency(val) {
      if (typeof val === 'number') return '$' + val.toFixed(2);
      return val;
    }
  },
  created() {
    this.cargarRecaudadoras();
  },
  methods: {
    async cargarRecaudadoras() {
      // Simulación: en producción, llamar a /api/execute con action 'listarRecaudadoras'
      // Aquí se simula con datos estáticos
      this.recaudadoras = [
        { id: 1, nombre: 'Zona Centro' },
        { id: 2, nombre: 'Zona Olímpica' },
        { id: 3, nombre: 'Zona Oblatos' },
        { id: 4, nombre: 'Zona Minerva' },
        { id: 5, nombre: 'Cruz del Sur' }
      ];
    },
    async listarMercados() {
      this.mercados = [];
      this.form.mercado = '';
      if (!this.form.oficina) return;
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: {
              action: 'listarMercados',
              oficina: this.form.oficina
            }
          })
        });
        const data = await res.json();
        this.mercados = data.eResponse.mercados || [];
      } catch (e) {
        this.error = 'Error al cargar mercados';
      }
    },
    async emitirRecibos() {
      this.error = '';
      this.success = '';
      this.recibos = [];
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: {
              action: 'emitirRecibos',
              oficina: this.form.oficina,
              mercado: this.form.mercado,
              axo: this.form.axo,
              periodo: this.form.periodo,
              usuario_id: 1 // Simulación
            }
          })
        });
        const data = await res.json();
        if (data.eResponse.recibos) {
          this.recibos = data.eResponse.recibos;
          this.success = 'Recibos generados correctamente';
        } else {
          this.error = data.eResponse.error || 'No se generaron recibos';
        }
      } catch (e) {
        this.error = 'Error al emitir recibos';
      }
    },
    async grabarEmision() {
      this.error = '';
      this.success = '';
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: {
              action: 'grabarEmision',
              oficina: this.form.oficina,
              mercado: this.form.mercado,
              axo: this.form.axo,
              periodo: this.form.periodo,
              usuario_id: 1 // Simulación
            }
          })
        });
        const data = await res.json();
        if (data.eResponse.status === 'ok') {
          this.success = data.eResponse.message;
        } else {
          this.error = data.eResponse.error || 'No se pudo grabar la emisión';
        }
      } catch (e) {
        this.error = 'Error al grabar emisión';
      }
    },
    async facturacion() {
      this.error = '';
      this.success = '';
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: {
              action: 'facturacion',
              oficina: this.form.oficina,
              mercado: this.form.mercado,
              axo: this.form.axo,
              periodo: this.form.periodo,
              solo_mercado: true
            }
          })
        });
        const data = await res.json();
        if (data.eResponse.facturacion) {
          this.success = 'Facturación generada correctamente';
        } else {
          this.error = data.eResponse.error || 'No se pudo generar la facturación';
        }
      } catch (e) {
        this.error = 'Error al generar facturación';
      }
    },
    async verDetalle(id_local) {
      this.error = '';
      try {
        const res = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: {
              action: 'detalleLocal',
              id_local
            }
          })
        });
        const data = await res.json();
        this.detalleLocal = data.eResponse.local || null;
      } catch (e) {
        this.error = 'Error al obtener detalle del local';
      }
    }
  }
};
</script>

<style scoped>
.emision-locales-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem;
}
.breadcrumb {
  background: none;
  padding: 0;
  margin-bottom: 1rem;
}
.modal {
  background: rgba(0,0,0,0.3);
}
</style>
