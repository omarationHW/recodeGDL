<template>
  <div class="municipal-form-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Gestión de Giros con Adeudos</li>
      </ol>
    </nav>

    <!-- Panel de Filtros y Búsqueda -->
    <div class="municipal-card mb-4">
      <div class="municipal-card-header text-center">
        <i class="fas fa-money-bill-wave me-2"></i>GESTIÓN DE GIROS CON ADEUDOS - CONTROL DE COBRANZA
      </div>
      <div class="municipal-card-body">
        <form @submit.prevent="buscarAdeudos">
          <div class="row">
            <div class="col-md-3">
              <label for="year" class="municipal-form-label">Año del adeudo:</label>
              <input
                type="number"
                min="1900"
                max="2100"
                class="municipal-form-control"
                id="year"
                v-model.number="filtros.year"
                placeholder="Ej: 2024"
              />
            </div>
            <div class="col-md-3">
              <label for="giro" class="municipal-form-label">Filtrar por giro:</label>
              <input
                type="text"
                class="municipal-form-control"
                id="giro"
                v-model="filtros.giro"
                placeholder="Descripción del giro"
              />
            </div>
            <div class="col-md-3">
              <label for="estado" class="municipal-form-label">Estado del adeudo:</label>
              <select class="municipal-form-control" id="estado" v-model="filtros.estado">
                <option value="">Todos</option>
                <option value="PENDIENTE">Pendientes</option>
                <option value="PAGADO">Pagados</option>
                <option value="VENCIDO">Vencidos</option>
              </select>
            </div>
            <div class="col-md-3 d-flex align-items-end gap-2">
              <button type="submit" class="btn-municipal-primary" :disabled="loading">
                <i class="fa fa-search"></i> {{ loading ? 'Buscando...' : 'Buscar' }}
              </button>
              <button type="button" class="btn-municipal-secondary" @click="generarDatosSimulados">
                <i class="fa fa-database"></i> Simular
              </button>
            </div>
          </div>
        </form>
        <div v-if="error" class="municipal-alert-danger mt-3">{{ error }}</div>
        <div v-if="message && !error" class="municipal-alert-info mt-3">{{ message }}</div>
      </div>
    </div>

    <!-- Panel de Estadísticas -->
    <div v-if="estadisticas && estadisticas.length > 0" class="municipal-card mb-4">
      <div class="municipal-card-header">
        <i class="fas fa-chart-bar me-2"></i>Estadísticas de Adeudos
      </div>
      <div class="municipal-card-body">
        <div class="row">
          <div v-for="stat in estadisticas" :key="stat.concepto" class="col-md-3 mb-3">
            <div class="municipal-stat-box">
              <div class="stat-label">{{ stat.concepto }}</div>
              <div class="stat-number">{{ stat.cantidad }}</div>
              <div class="stat-amount">${{ formatearMonto(stat.monto_total) }}</div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Tabla de Resultados -->
    <div v-if="reportData && reportData.length > 0" class="municipal-card">
      <div class="municipal-card-header d-flex justify-content-between align-items-center">
        <span>
          Giros con Adeudos <span v-if="filtros.year">(Año: {{ filtros.year }})</span>
          - Total: <strong>{{ reportData.length }}</strong>
        </span>
        <div class="btn-group">
          <button class="btn-municipal-secondary btn-sm" @click="exportarExcel">
            <i class="fa fa-file-excel"></i> Excel
          </button>
          <button class="btn-municipal-secondary btn-sm" @click="imprimirReporte">
            <i class="fa fa-print"></i> Imprimir
          </button>
        </div>
      </div>
      <div class="municipal-card-body p-0">
        <div class="table-responsive">
          <table class="municipal-table table-bordered table-sm mb-0">
            <thead class="municipal-table-header">
              <tr>
                <th>Licencia</th>
                <th>Propietario</th>
                <th>Ubicación</th>
                <th>Giro</th>
                <th>Año</th>
                <th>Monto Adeudo</th>
                <th>Estado</th>
                <th>Días Vencido</th>
                <th>Acciones</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="row in reportData" :key="`${row.licencia}-${row.axo}`"
                  :class="{'table-danger': row.dias_vencido > 30, 'table-warning': row.dias_vencido > 0 && row.dias_vencido <= 30}">
                <td>{{ row.licencia }}</td>
                <td>{{ row.propietarionvo }}</td>
                <td>{{ row.domCompleto }}</td>
                <td>{{ row.descripcion }}</td>
                <td>{{ row.axo }}</td>
                <td class="text-right">${{ formatearMonto(row.monto_adeudo) }}</td>
                <td>
                  <span :class="getEstadoClass(row.estado_adeudo, row.dias_vencido)">
                    {{ getEstadoTexto(row.estado_adeudo, row.dias_vencido) }}
                  </span>
                </td>
                <td class="text-center">
                  <span v-if="row.dias_vencido > 0" class="badge badge-danger">
                    {{ row.dias_vencido }}
                  </span>
                  <span v-else class="text-muted">-</span>
                </td>
                <td>
                  <div class="btn-group btn-group-sm">
                    <button class="btn btn-outline-primary btn-xs"
                            @click="verDetalle(row.licencia, row.axo)"
                            title="Ver detalle">
                      <i class="fa fa-eye"></i>
                    </button>
                    <button v-if="row.estado_adeudo === 'PENDIENTE'"
                            class="btn btn-outline-success btn-xs"
                            @click="registrarPago(row)"
                            title="Registrar pago">
                      <i class="fa fa-money-bill"></i>
                    </button>
                    <button class="btn btn-outline-warning btn-xs"
                            @click="editarAdeudo(row)"
                            title="Editar">
                      <i class="fa fa-edit"></i>
                    </button>
                  </div>
                </td>
              </tr>
            </tbody>
            <tfoot>
              <tr>
                <td colspan="5" class="text-right font-weight-bold">Totales:</td>
                <td class="text-right font-weight-bold">${{ formatearMonto(getTotalAdeudos()) }}</td>
                <td colspan="3" class="font-weight-bold">{{ reportData.length }} registros</td>
              </tr>
            </tfoot>
          </table>
        </div>
      </div>
    </div>
    <div v-else-if="reportData && reportData.length === 0 && !error" class="municipal-alert-warning mt-3">
      No se encontraron giros con adeudos para los criterios especificados.
    </div>

    <!-- Modal para Detalle de Adeudo -->
    <div v-if="showDetalleModal" class="modal fade show d-block" style="background-color: rgba(0,0,0,0.5)">
      <div class="modal-dialog modal-lg">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">
              <i class="fa fa-info-circle"></i> Detalle de Adeudo - Licencia {{ detalleAdeudo.licencia }}
            </h5>
            <button type="button" class="btn-close" @click="cerrarDetalle"></button>
          </div>
          <div class="modal-body" v-if="detalleAdeudo">
            <div class="row">
              <div class="col-md-6">
                <h6>Información de la Licencia</h6>
                <p><strong>Licencia:</strong> {{ detalleAdeudo.licencia }}</p>
                <p><strong>Propietario:</strong> {{ detalleAdeudo.propietarionvo }}</p>
                <p><strong>Ubicación:</strong> {{ detalleAdeudo.domCompleto }}</p>
                <p><strong>Giro:</strong> {{ detalleAdeudo.giro_descripcion }}</p>
              </div>
              <div class="col-md-6">
                <h6>Información del Adeudo</h6>
                <p><strong>Año:</strong> {{ detalleAdeudo.axo }}</p>
                <p><strong>Monto Original:</strong> ${{ formatearMonto(detalleAdeudo.monto_original) }}</p>
                <p><strong>Recargos:</strong> ${{ formatearMonto(detalleAdeudo.recargos) }}</p>
                <p><strong>Monto Total:</strong> ${{ formatearMonto(detalleAdeudo.monto_total) }}</p>
                <p><strong>Estado:</strong> {{ detalleAdeudo.estado }}</p>
                <p><strong>Fecha Vencimiento:</strong> {{ formatearFecha(detalleAdeudo.fecha_vencimiento) }}</p>
                <p v-if="detalleAdeudo.fecha_pago"><strong>Fecha Pago:</strong> {{ formatearFecha(detalleAdeudo.fecha_pago) }}</p>
                <p v-if="detalleAdeudo.referencia_pago"><strong>Referencia Pago:</strong> {{ detalleAdeudo.referencia_pago }}</p>
              </div>
            </div>
            <div v-if="detalleAdeudo.observaciones" class="mt-3">
              <h6>Observaciones</h6>
              <p>{{ detalleAdeudo.observaciones }}</p>
            </div>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary" @click="cerrarDetalle">Cerrar</button>
          </div>
        </div>
      </div>
    </div>

    <!-- Modal para Registrar Pago -->
    <div v-if="showPagoModal" class="modal fade show d-block" style="background-color: rgba(0,0,0,0.5)">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header">
            <h5 class="modal-title">
              <i class="fa fa-money-bill"></i> Registrar Pago - Licencia {{ pagoForm.licencia }}
            </h5>
            <button type="button" class="btn-close" @click="cerrarPago"></button>
          </div>
          <form @submit.prevent="confirmarPago">
            <div class="modal-body">
              <div class="mb-3">
                <label class="municipal-form-label">Monto a Pagar</label>
                <input type="number" step="0.01" class="municipal-form-control"
                       v-model="pagoForm.monto_pagado" required>
              </div>
              <div class="mb-3">
                <label class="municipal-form-label">Referencia de Pago</label>
                <input type="text" class="municipal-form-control"
                       v-model="pagoForm.referencia_pago" maxlength="50" required>
              </div>
              <div class="mb-3">
                <label class="municipal-form-label">Fecha de Pago</label>
                <input type="date" class="municipal-form-control"
                       v-model="pagoForm.fecha_pago" required>
              </div>
              <div class="mb-3">
                <label class="municipal-form-label">Observaciones</label>
                <textarea class="municipal-form-control" rows="3"
                          v-model="pagoForm.observaciones_pago"></textarea>
              </div>
            </div>
            <div class="modal-footer">
              <button type="button" class="btn btn-secondary" @click="cerrarPago">Cancelar</button>
              <button type="submit" class="btn btn-success" :disabled="loading">
                <i class="fa fa-check"></i> {{ loading ? 'Procesando...' : 'Confirmar Pago' }}
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'GirosDconAdeudoForm',
  data() {
    return {
      // Filtros de búsqueda
      filtros: {
        year: new Date().getFullYear(),
        giro: '',
        estado: 'PENDIENTE'
      },
      // Datos de la tabla
      reportData: [],
      estadisticas: [],
      // Estados de la aplicación
      loading: false,
      error: '',
      message: '',
      // Modales
      showDetalleModal: false,
      showPagoModal: false,
      detalleAdeudo: null,
      pagoForm: {
        id: null,
        licencia: '',
        monto_pagado: 0,
        referencia_pago: '',
        fecha_pago: new Date().toISOString().split('T')[0],
        observaciones_pago: ''
      }
    };
  },
  mounted() {
    this.cargarEstadisticas();
  },
  methods: {
    // =================== MÉTODOS PRINCIPALES ===================
    async buscarAdeudos() {
      this.loading = true;
      this.error = '';
      this.message = '';
      this.reportData = [];

      try {
        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            eRequest: {
              Operacion: 'SP_GIROS_CON_ADEUDO_LIST',
              Base: 'padron_licencias',
              Parametros: [
                { nombre: 'p_year', valor: this.filtros.year || null },
                { nombre: 'p_giro', valor: this.filtros.giro || null },
                { nombre: 'p_estado', valor: this.filtros.estado || null }
              ],
              Tenant: 'guadalajara'
            }
          })
        });

        const data = await response.json();

        if (data.eResponse && data.eResponse.success) {
          this.reportData = data.eResponse.data.result || [];
          this.message = this.reportData.length > 0 ?
            `Se encontraron ${this.reportData.length} giros con adeudos` :
            'No se encontraron giros con adeudos para los criterios especificados';

          // Actualizar estadísticas después de la búsqueda
          await this.cargarEstadisticas();
        } else {
          this.error = data.eResponse?.message || 'Error al buscar adeudos';
        }
      } catch (err) {
        this.error = 'Error de comunicación con el servidor';
        console.error('Error:', err);
      } finally {
        this.loading = false;
      }
    },

    async cargarEstadisticas() {
      try {
        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            eRequest: {
              Operacion: 'SP_GIROS_CON_ADEUDO_ESTADISTICAS',
              Base: 'padron_licencias',
              Parametros: [
                { nombre: 'p_year', valor: this.filtros.year || null },
                { nombre: 'p_mes', valor: new Date().getMonth() + 1 }
              ],
              Tenant: 'guadalajara'
            }
          })
        });

        const data = await response.json();

        if (data.eResponse && data.eResponse.success) {
          this.estadisticas = data.eResponse.data.result || [];
        }
      } catch (err) {
        console.error('Error al cargar estadísticas:', err);
      }
    },

    async verDetalle(licencia, year) {
      this.loading = true;
      try {
        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            eRequest: {
              Operacion: 'SP_GIROS_CON_ADEUDO_GET',
              Base: 'padron_licencias',
              Parametros: [
                { nombre: 'p_licencia', valor: licencia },
                { nombre: 'p_year', valor: year }
              ],
              Tenant: 'guadalajara'
            }
          })
        });

        const data = await response.json();

        if (data.eResponse && data.eResponse.success && data.eResponse.data.result.length > 0) {
          this.detalleAdeudo = data.eResponse.data.result[0];
          this.showDetalleModal = true;
        } else {
          this.error = 'No se pudo cargar el detalle del adeudo';
        }
      } catch (err) {
        this.error = 'Error al cargar detalle';
        console.error('Error:', err);
      } finally {
        this.loading = false;
      }
    },

    registrarPago(adeudo) {
      this.pagoForm = {
        id: adeudo.id,
        licencia: adeudo.licencia,
        monto_pagado: adeudo.monto_adeudo,
        referencia_pago: `PAG-${adeudo.licencia}-${new Date().getFullYear()}`,
        fecha_pago: new Date().toISOString().split('T')[0],
        observaciones_pago: ''
      };
      this.showPagoModal = true;
    },

    async confirmarPago() {
      this.loading = true;
      this.error = '';

      try {
        const response = await fetch('http://localhost:8000/api/generic', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({
            eRequest: {
              Operacion: 'SP_GIROS_CON_ADEUDO_PAGAR',
              Base: 'padron_licencias',
              Parametros: [
                { nombre: 'p_id', valor: this.pagoForm.id },
                { nombre: 'p_monto_pagado', valor: this.pagoForm.monto_pagado },
                { nombre: 'p_referencia_pago', valor: this.pagoForm.referencia_pago },
                { nombre: 'p_fecha_pago', valor: this.pagoForm.fecha_pago },
                { nombre: 'p_observaciones_pago', valor: this.pagoForm.observaciones_pago }
              ],
              Tenant: 'guadalajara'
            }
          })
        });

        const data = await response.json();

        if (data.eResponse && data.eResponse.success) {
          this.message = 'Pago registrado exitosamente';
          this.showPagoModal = false;
          await this.buscarAdeudos(); // Recargar datos
        } else {
          this.error = data.eResponse?.message || 'Error al registrar el pago';
        }
      } catch (err) {
        this.error = 'Error de comunicación con el servidor';
        console.error('Error:', err);
      } finally {
        this.loading = false;
      }
    },

    editarAdeudo(adeudo) {
      // Implementar modal de edición si es necesario
      this.$router.push(`/licencias/adeudo/editar/${adeudo.licencia}/${adeudo.axo}`);
    },

    // =================== MÉTODOS DE UTILIDAD ===================
    generarDatosSimulados() {
      const giros = [
        'ABARROTES Y MISCELANEAS',
        'RESTAURANTE',
        'FARMACIA',
        'TALLER MECANICO',
        'CONSULTORIO MEDICO',
        'ESTÉTICA',
        'PANADERÍA',
        'CARNICERÍA'
      ];

      const propietarios = [
        'JUAN CARLOS MARTÍNEZ LÓPEZ',
        'MARÍA ELENA RODRÍGUEZ SILVA',
        'CARLOS ALBERTO HERNÁNDEZ VEGA',
        'ANA PATRICIA GARCÍA MORALES',
        'LUIS FERNANDO TORRES RAMOS',
        'SOFIA ALEJANDRA MENDOZA CRUZ'
      ];

      const calles = [
        'AV. JUÁREZ #123, COL. CENTRO',
        'CALLE MORELOS #456, COL. AMERICANA',
        'AV. LÓPEZ MATEOS #789, COL. CHAPALITA',
        'CALLE HIDALGO #321, COL. MODERNA',
        'AV. VALLARTA #654, COL. PROVIDENCIA'
      ];

      this.reportData = Array.from({ length: 15 }, (_, index) => {
        const diasVencido = Math.floor(Math.random() * 120);
        const montoBase = Math.random() * 50000 + 5000;

        return {
          licencia: `LIC${(20240001 + index).toString()}`,
          propietarionvo: propietarios[Math.floor(Math.random() * propietarios.length)],
          domCompleto: calles[Math.floor(Math.random() * calles.length)],
          descripcion: giros[Math.floor(Math.random() * giros.length)],
          axo: this.filtros.year || 2024,
          monto_adeudo: Number(montoBase.toFixed(2)),
          estado_adeudo: diasVencido > 60 ? 'PENDIENTE' : (Math.random() > 0.3 ? 'PENDIENTE' : 'PAGADO'),
          fecha_vencimiento: new Date(2024, 11, 31),
          dias_vencido: diasVencido > 0 ? diasVencido : 0,
          id: index + 1
        };
      });

      // Generar estadísticas simuladas
      this.estadisticas = [
        {
          concepto: 'Adeudos Pendientes',
          cantidad: this.reportData.filter(r => r.estado_adeudo === 'PENDIENTE').length,
          monto_total: this.reportData
            .filter(r => r.estado_adeudo === 'PENDIENTE')
            .reduce((sum, r) => sum + r.monto_adeudo, 0)
        },
        {
          concepto: 'Adeudos Pagados',
          cantidad: this.reportData.filter(r => r.estado_adeudo === 'PAGADO').length,
          monto_total: this.reportData
            .filter(r => r.estado_adeudo === 'PAGADO')
            .reduce((sum, r) => sum + r.monto_adeudo, 0)
        },
        {
          concepto: 'Adeudos Vencidos',
          cantidad: this.reportData.filter(r => r.dias_vencido > 0).length,
          monto_total: this.reportData
            .filter(r => r.dias_vencido > 0)
            .reduce((sum, r) => sum + r.monto_adeudo, 0)
        },
        {
          concepto: 'Promedio por Licencia',
          cantidad: this.reportData.length,
          monto_total: this.reportData.reduce((sum, r) => sum + r.monto_adeudo, 0) / this.reportData.length
        }
      ];

      this.message = `Datos simulados generados: ${this.reportData.length} registros`;
    },

    formatearMonto(monto) {
      if (!monto && monto !== 0) return '0.00';
      return Number(monto).toLocaleString('es-MX', {
        minimumFractionDigits: 2,
        maximumFractionDigits: 2
      });
    },

    formatearFecha(fecha) {
      if (!fecha) return '-';
      return new Date(fecha).toLocaleDateString('es-MX');
    },

    getEstadoClass(estado, diasVencido) {
      if (estado === 'PAGADO') return 'badge badge-success';
      if (diasVencido > 30) return 'badge badge-danger';
      if (diasVencido > 0) return 'badge badge-warning';
      return 'badge badge-info';
    },

    getEstadoTexto(estado, diasVencido) {
      if (estado === 'PAGADO') return 'PAGADO';
      if (diasVencido > 30) return 'VENCIDO';
      if (diasVencido > 0) return 'POR VENCER';
      return 'VIGENTE';
    },

    getTotalAdeudos() {
      return this.reportData.reduce((total, row) => total + (row.monto_adeudo || 0), 0);
    },

    // =================== MÉTODOS DE MODALES ===================
    cerrarDetalle() {
      this.showDetalleModal = false;
      this.detalleAdeudo = null;
    },

    cerrarPago() {
      this.showPagoModal = false;
      this.pagoForm = {
        id: null,
        licencia: '',
        monto_pagado: 0,
        referencia_pago: '',
        fecha_pago: new Date().toISOString().split('T')[0],
        observaciones_pago: ''
      };
    },

    // =================== MÉTODOS DE EXPORTACIÓN ===================
    exportarExcel() {
      // Implementar exportación a Excel
      const csvContent = this.convertirACSV();
      const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
      const link = document.createElement('a');
      link.href = URL.createObjectURL(blob);
      link.download = `giros_adeudos_${this.filtros.year || 'todos'}.csv`;
      link.click();
    },

    convertirACSV() {
      const headers = ['Licencia', 'Propietario', 'Ubicación', 'Giro', 'Año', 'Monto Adeudo', 'Estado', 'Días Vencido'];
      const rows = this.reportData.map(row => [
        row.licencia,
        row.propietarionvo,
        row.domCompleto,
        row.descripcion,
        row.axo,
        row.monto_adeudo,
        this.getEstadoTexto(row.estado_adeudo, row.dias_vencido),
        row.dias_vencido
      ]);

      return [headers, ...rows]
        .map(row => row.map(field => `"${field}"`).join(','))
        .join('\n');
    },

    imprimirReporte() {
      const printContents = this.$el.querySelector('.municipal-card:last-of-type').outerHTML;
      const win = window.open('', '', 'width=1200,height=800');
      win.document.write(`
        <html>
          <head>
            <title>Reporte de Giros con Adeudos</title>
            <style>
              body { font-family: Arial, sans-serif; margin: 20px; }
              .municipal-table { width: 100%; border-collapse: collapse; }
              .municipal-table th, .municipal-table td { border: 1px solid #ddd; padding: 8px; text-align: left; }
              .municipal-table-header { background-color: #f5f5f5; }
              .text-right { text-align: right; }
              .font-weight-bold { font-weight: bold; }
              @media print {
                body { margin: 0; }
                .btn-group { display: none; }
              }
            </style>
          </head>
          <body>
            <h2>Gestión de Giros con Adeudos</h2>
            <p>Fecha de impresión: ${new Date().toLocaleDateString('es-MX')}</p>
            ${printContents}
          </body>
        </html>
      `);
      win.document.close();
      win.focus();
      win.print();
      win.close();
    }
  }
};
</script>

<style scoped>
.municipal-stat-box {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  padding: 20px;
  border-radius: 10px;
  text-align: center;
  box-shadow: 0 4px 6px rgba(0,0,0,0.1);
}

.stat-label {
  font-size: 14px;
  opacity: 0.9;
  margin-bottom: 5px;
}

.stat-number {
  font-size: 24px;
  font-weight: bold;
  margin-bottom: 5px;
}

.stat-amount {
  font-size: 16px;
  font-weight: 600;
}

.table-danger {
  background-color: rgba(220, 53, 69, 0.1);
}

.table-warning {
  background-color: rgba(255, 193, 7, 0.1);
}

.btn-xs {
  padding: 0.25rem 0.4rem;
  font-size: 0.75rem;
  line-height: 1.5;
  border-radius: 0.2rem;
}

.gap-2 {
  gap: 0.5rem;
}

.modal {
  z-index: 1050;
}

.badge {
  display: inline-block;
  padding: 0.25em 0.4em;
  font-size: 75%;
  font-weight: 700;
  line-height: 1;
  text-align: center;
  white-space: nowrap;
  vertical-align: baseline;
  border-radius: 0.25rem;
}

.badge-success { color: #fff; background-color: #28a745; }
.badge-danger { color: #fff; background-color: #dc3545; }
.badge-warning { color: #212529; background-color: #ffc107; }
.badge-info { color: #fff; background-color: #17a2b8; }
</style>

