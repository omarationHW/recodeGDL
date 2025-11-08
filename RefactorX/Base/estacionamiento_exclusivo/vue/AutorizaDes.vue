<template>
  <div class="autoriza-des-page">
    <h1>Descuentos Autorizados</h1>
    <div class="breadcrumb">
      <router-link to="/">Inicio</router-link> / Descuentos Autorizados
    </div>
    <form @submit.prevent="buscarFolio">
      <div class="form-row">
        <label>Oficina:</label>
        <select v-model="form.id_rec" required>
          <option v-for="of in oficinas" :key="of.id_rec" :value="of.id_rec">{{ of.nombre }}</option>
        </select>
        <label>Aplicación:</label>
        <select v-model="form.id_modulo" required>
          <option v-for="ap in aplicaciones" :key="ap.id_modulo" :value="ap.id_modulo">{{ ap.descripcion }}</option>
        </select>
        <label>Folio Req:</label>
        <input type="number" v-model="form.folio" min="1" required />
        <button type="submit">Buscar</button>
      </div>
    </form>
    <div v-if="folioData">
      <h2>Datos del Folio</h2>
      <div class="folio-info">
        <div><strong>Datos de Registro:</strong> {{ folioData.datos }}</div>
        <div><strong>Impuesto Requerido:</strong> {{ folioData.importe_global }}</div>
        <div><strong>Recargos:</strong> {{ folioData.importe_recargo }}</div>
        <div><strong>Multas:</strong> {{ folioData.importe_multa }}</div>
        <div><strong>Gastos:</strong> {{ folioData.importe_gastos }}</div>
        <div><strong>Fecha Emitido:</strong> {{ folioData.fecha_emision }}</div>
        <div><strong>Fecha Practicado:</strong> {{ folioData.fecha_practicado }}</div>
      </div>
      <div v-if="autorizado">
        <h3>Descuento Vigente</h3>
        <div><strong>Porcentaje:</strong> {{ autorizado.porcentaje }}%</div>
        <div><strong>Autorizado por:</strong> {{ autorizado.quien }}</div>
        <div><strong>Fecha Alta:</strong> {{ autorizado.fecha_alta }}</div>
        <div v-if="autorizado.fecha_baja"><strong>Fecha Baja:</strong> {{ autorizado.fecha_baja }}</div>
        <button @click="bajaDescuento">Dar de Baja</button>
      </div>
      <div v-else>
        <h3>Nuevo Descuento</h3>
        <form @submit.prevent="guardarDescuento">
          <div class="form-row">
            <label>Porcentaje Autorizado:</label>
            <input type="number" v-model.number="nuevoDescuento.porcentaje" min="1" max="100" required />
            <label>Autorizado por:</label>
            <select v-model="nuevoDescuento.cveaut" required>
              <option v-for="q in quienes" :key="q.cveaut" :value="q.cveaut">{{ q.quien }}</option>
            </select>
            <label>Fecha Alta:</label>
            <input type="date" v-model="nuevoDescuento.fecha_alta" required />
            <button type="submit">Guardar</button>
          </div>
        </form>
      </div>
    </div>
    <div v-if="mensaje" class="mensaje">{{ mensaje }}</div>
  </div>
</template>

<script>
export default {
  name: 'AutorizaDesPage',
  data() {
    return {
      form: {
        id_rec: '',
        id_modulo: '',
        folio: ''
      },
      oficinas: [],
      aplicaciones: [],
      quienes: [],
      folioData: null,
      autorizado: null,
      nuevoDescuento: {
        porcentaje: '',
        cveaut: '',
        fecha_alta: ''
      },
      mensaje: ''
    };
  },
  created() {
    this.cargarCatalogos();
  },
  methods: {
    async cargarCatalogos() {
      // Cargar oficinas
      let resp = await this.api('catalogo_oficina', {});
      this.oficinas = resp.result;
      // Cargar aplicaciones
      resp = await this.api('catalogo_aplicacion', {});
      this.aplicaciones = resp.result;
      // Cargar quienes pueden autorizar
      resp = await this.api('catalogo_quien', { usuario_id: this.getUsuarioId() });
      this.quienes = resp.result;
    },
    async buscarFolio() {
      this.mensaje = '';
      const params = {
        action: 'search',
        folio: this.form.folio,
        id_rec: this.form.id_rec,
        id_modulo: this.form.id_modulo,
        usuario_id: this.getUsuarioId()
      };
      const resp = await this.api('search', params);
      if (resp.result && resp.result.length > 0) {
        this.folioData = resp.result[0];
        // Buscar si tiene descuento vigente
        if (this.folioData.autorizados && this.folioData.autorizados.length > 0) {
          this.autorizado = this.folioData.autorizados[0];
        } else {
          this.autorizado = null;
        }
      } else {
        this.folioData = null;
        this.autorizado = null;
        this.mensaje = 'No existe el folio o no se encuentra practicado o vigente';
      }
    },
    async guardarDescuento() {
      this.mensaje = '';
      if (this.nuevoDescuento.porcentaje > this.getTopePorcentaje(this.nuevoDescuento.cveaut)) {
        this.mensaje = 'Porcentaje de Descuento es mayor al permitido por quien autoriza';
        return;
      }
      const params = {
        action: 'alta',
        id_control: this.folioData.id_control,
        id_rec: this.form.id_rec,
        cveaut: this.nuevoDescuento.cveaut,
        porcentaje: this.nuevoDescuento.porcentaje,
        fecha_alta: this.nuevoDescuento.fecha_alta,
        usuario_id: this.getUsuarioId()
      };
      const resp = await this.api('alta', params);
      if (resp.error) {
        this.mensaje = resp.error;
      } else {
        this.mensaje = 'Se ha dado de alta el descuento';
        this.buscarFolio();
      }
    },
    async bajaDescuento() {
      if (!confirm('¿Desea dar de Baja el Descuento?')) return;
      const params = {
        action: 'baja',
        id_control: this.folioData.id_control,
        fecha_baja: new Date().toISOString().substr(0, 10),
        usuario_id: this.getUsuarioId()
      };
      const resp = await this.api('baja', params);
      if (resp.error) {
        this.mensaje = resp.error;
      } else {
        this.mensaje = 'Se ha cancelado el descuento';
        this.buscarFolio();
      }
    },
    getUsuarioId() {
      // Implementar según autenticación
      return 1;
    },
    getTopePorcentaje(cveaut) {
      const q = this.quienes.find(q => q.cveaut === cveaut);
      return q ? q.porcentajetope : 100;
    },
    async api(action, params) {
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ eRequest: { ...params, action } })
      });
      const data = await res.json();
      return data.eResponse;
    }
  }
};
</script>

<style scoped>
.autoriza-des-page {
  max-width: 800px;
  margin: 0 auto;
  padding: 2rem;
}
.breadcrumb {
  margin-bottom: 1rem;
  font-size: 0.9rem;
}
.form-row {
  display: flex;
  align-items: center;
  gap: 1rem;
  margin-bottom: 1rem;
}
.folio-info {
  background: #f8f8f8;
  padding: 1rem;
  border-radius: 4px;
  margin-bottom: 1rem;
}
.mensaje {
  margin-top: 1rem;
  color: #b00;
}
</style>
